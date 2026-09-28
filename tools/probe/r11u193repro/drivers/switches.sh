#!/bin/bash
# r11u193: each switch alone.  For every case dir of this pass: the law binary's database with one
# R11U193_<LAW>_OFF set vs without; prints, per switch, the cases whose bytes move.  usage: switches.sh <out dir>
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
O=$1; rm -rf $O; mkdir -p $O
CASES=$(cd "$D/../cases" && find . -name 'dut.sv' | sed 's#^\./##; s#/dut.sv$##' | sort)
for c in $CASES; do n=${c//\//__}; ( cd "$D/../cases/$c" && $R193_BIN/law.bin dut.sv --single-unit --nobuiltin -o $O/$n.law.uhdm >/dev/null 2>&1 ); done
for sw in CASTLEAF CASTTSNAME SYSARGDEF TERNFILL UNSIZEDCLONE NESTNAME COPYORDER; do
  mv=""; k=0
  for c in $CASES; do n=${c//\//__}
    ( cd "$D/../cases/$c" && env R11U193_${sw}_OFF=1 $R193_BIN/law.bin dut.sv --single-unit --nobuiltin -o $O/$n.$sw.uhdm >/dev/null 2>&1 )
    cmp -s $O/$n.law.uhdm $O/$n.$sw.uhdm || { mv="$mv $c"; k=$((k+1)); }; done
  echo "R11U193_${sw}_OFF moves $k:$mv"; done
