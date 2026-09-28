#!/bin/bash
# r11u193: R11U193_OFF=1 on the law binary must give the pristine bytes.  Exports every tests/probe case and every
# case dir of this pass with `$R193_BIN/law.bin` under R11U193_OFF=1 (cwd = the case dir, `dut.sv --single-unit
# --nobuiltin`) and byte-compares with the pristine binary's database of the same case.
# usage: offcheck.sh <pristine sweep workdir> <out dir>   (fence: refuses fenced paths)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
W=$1; O=$2; rm -rf $O; mkdir -p $O/probe $O/cases
same=0; differ=0; list=""
for d in $(cd "$R193_REPO/tests/probe" && find . -name dut.sv | sed 's#^\./##; s#/dut.sv$##' | sort); do
  r193_fenced "$d" && continue
  n=${d//\//__}; ( cd "$R193_REPO/tests/probe/$d" && R11U193_OFF=1 $R193_BIN/law.bin dut.sv --single-unit --nobuiltin -o $O/probe/$n.uhdm >/dev/null 2>&1 )
  if cmp -s $O/probe/$n.uhdm $W/probe/$n.uhdm; then same=$((same+1)); else differ=$((differ+1)); list="$list $d"; fi
done
echo "probe same=$same differ=$differ$list"
cs=0; cd_=0; cl=""
for c in $(cd "$D/../cases" && find . -name 'dut.sv' | sed 's#^\./##; s#/dut.sv$##' | sort); do
  n=${c//\//__}
  ( cd "$D/../cases/$c" && R11U193_OFF=1 $R193_BIN/law.bin dut.sv --single-unit --nobuiltin -o $O/cases/$n.off.uhdm >/dev/null 2>&1;
    $R193_BIN/pris.bin dut.sv --single-unit --nobuiltin -o $O/cases/$n.pris.uhdm >/dev/null 2>&1 )
  if cmp -s $O/cases/$n.off.uhdm $O/cases/$n.pris.uhdm; then cs=$((cs+1)); else cd_=$((cd_+1)); cl="$cl $c"; fi
done
echo "cases same=$cs differ=$cd_$cl"
