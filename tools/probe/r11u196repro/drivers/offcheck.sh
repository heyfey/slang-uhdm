#!/bin/bash
# r11u196: R11U196_OFF=1 on the law binary must give the pristine bytes.  Exports every tests/probe case and every
# case dir under this pass's cases/ and tools/probe/r11u191dec/cases/ with `$R196_BIN/law.bin` under R11U196_OFF=1
# (cwd = the case dir, `<root files> --single-unit --nobuiltin`) and byte-compares with the pristine binary's database:
# the pristine gate sweep's probe database for a probe case, a fresh pristine export for a case dir.
# usage: offcheck.sh <pristine sweep workdir> <out dir> [ENV=1 ...]  (extra env: a single-switch run, e.g.
# R11U196_MODGENERIC_OFF=1 without R11U196_OFF, reports which cases that switch alone restores)  (fence: refuses fenced paths)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
W=$1; O=$2; shift 2; EV="${*:-R11U196_OFF=1}"; rm -rf $O; mkdir -p $O/probe $O/cases
same=0; differ=0; list=""
for d in $(cd "$R196_REPO/tests/probe" && find . -name dut.sv | sed 's#^\./##; s#/dut.sv$##' | sort); do
  r196_fenced "$d" && continue
  n=${d//\//__}; ( cd "$R196_REPO/tests/probe/$d" && env $EV $R196_BIN/law.bin dut.sv --single-unit --nobuiltin -o $O/probe/$n.uhdm >/dev/null 2>&1 )
  if cmp -s $O/probe/$n.uhdm $W/probe/$n.uhdm; then same=$((same+1)); rm -f $O/probe/$n.uhdm; else differ=$((differ+1)); list="$list $d"; fi
done
echo "probe same=$same differ=$differ$list"
cs=0; cd_=0; cl=""
for c in $(cd "$R196_REPO/tools/probe" && { find r11u196repro/cases r11u191dec/cases -name dut.sv -o -name args -o -name files; } | xargs -n1 dirname | sort -u); do
  r196_fenced "$c" && continue
  n=${c//\//__}; cc="$R196_REPO/tools/probe/$c"
  SRC=dut.sv; [ -f "$cc/args" ] && SRC=$(cat "$cc/args"); [ ! -f "$cc/args" ] && [ -f "$cc/files" ] && SRC=$(tr "\n" " " < "$cc/files")
  ( cd "$cc" && env $EV $R196_BIN/law.bin $SRC --single-unit --nobuiltin -o $O/cases/$n.off.uhdm >/dev/null 2>&1;
    $R196_BIN/pris.bin $SRC --single-unit --nobuiltin -o $O/cases/$n.pris.uhdm >/dev/null 2>&1 )
  if cmp -s $O/cases/$n.off.uhdm $O/cases/$n.pris.uhdm; then cs=$((cs+1)); else cd_=$((cd_+1)); cl="$cl $c"; fi
done
echo "cases same=$cs differ=$cd_$cl"
