#!/bin/bash
# r11u196: each switch alone.  For every case dir of this pass (cases/, and tools/probe/r11u191dec/cases for the r11u191
# switches): the law binary's database with one switch set vs without; prints, per switch, the cases whose bytes move.
# usage: switches.sh <out dir>   (fence: refuses fenced paths)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
O=$1; rm -rf $O; mkdir -p $O
CASES=$(cd "$R196_REPO/tools/probe" && { find r11u196repro/cases r11u191dec/cases -name dut.sv -o -name args -o -name files; } | xargs -n1 dirname | sort -u)
run() { local c=$1 out=$2; shift 2; local cc="$R196_REPO/tools/probe/$c" SRC=dut.sv
  [ -f "$cc/args" ] && SRC=$(cat "$cc/args"); [ ! -f "$cc/args" ] && [ -f "$cc/files" ] && SRC=$(tr "\n" " " < "$cc/files")
  ( cd "$cc" && env "$@" $R196_BIN/law.bin $SRC --single-unit --nobuiltin -o $out >/dev/null 2>&1 ); }
for c in $CASES; do r196_fenced "$c" && continue; n=${c//\//__}; run $c $O/$n.law.uhdm X=1; done
for sw in R11U196_MODGENERIC_OFF R11U196_MODGENHANDLE_OFF R11U196_MODCLSLINK_OFF R11U196_ELEMCLSNAME_OFF \
          R11U196_RETQUALTD_OFF R11U196_TPARRBOUND_OFF R11U196_DFLTARG_OFF R11U196_FORMALCLONEFILE_OFF \
          R11U191_REFFULL_OFF R11U191_CONSTCALL_OFF R11U191_UNSIZEDPKG_OFF R11U191_QUEUERANGE_OFF \
          R11U191_ENUMPARENT_OFF R11U191_HDRTD_OFF R11U191_REALPORT_OFF; do
  mv=""; k=0
  for c in $CASES; do r196_fenced "$c" && continue; n=${c//\//__}
    run $c $O/$n.$sw.uhdm $sw=1
    cmp -s $O/$n.law.uhdm $O/$n.$sw.uhdm || { mv="$mv ${c#r11u196repro/cases/}"; k=$((k+1)); }; rm -f $O/$n.$sw.uhdm; done
  echo "$sw moves $k:$mv"; done
