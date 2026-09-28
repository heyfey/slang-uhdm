#!/bin/bash
# r11u188: each r11u188 switch alone on the law binary, over this pass's case dirs (dut.sv; dut.v with TOP=dut.v):
# prints `<switch> moved=<n> <cases>`, the cases whose database differs from the law binary's with every switch on.
# usage: switches.sh <law binary, absolute> <outdir>
. "$(dirname "$0")/env.sh" || exit 3
L=$1; O=$2; rm -rf $O; mkdir -p $O
SW="R11U188_PROPLAST_OFF R11U188_BINDPARENT_OFF R11U188_TPKEYWORD_OFF R11U188_TPDEFSYN_OFF R11U188_TPINCORDER_OFF R11U188_SVMODE_OFF R11U188_OFF"
C=$R188_REPO/tools/probe/r11u188repro/cases
run() { # <dir> <out> [env]
  local d=$1 o=$2; shift 2; local top=dut.sv; [ -f $d/dut.v ] && top=dut.v; rm -f $o
  ( cd $d && env "$@" $L $top --single-unit --nobuiltin -o $o > /dev/null 2>&1 < /dev/null ) ; }
for d in $(find $C \( -name dut.sv -o -name dut.v \) -printf '%h\n' | sort -u); do
  r=${d#$C/}; mkdir -p $O/ref/$(dirname $r); run $d $O/ref/$r.uhdm
  for s in $SW; do mkdir -p $O/$s/$(dirname $r); run $d $O/$s/$r.uhdm $s=1; cmp -s $O/ref/$r.uhdm $O/$s/$r.uhdm || echo "$s $r" >> $O/moves.txt; done
done
touch $O/moves.txt
for s in $SW; do echo "$s moved=$(grep -c "^$s " $O/moves.txt) $(grep "^$s " $O/moves.txt | awk '{print $2}' | tr '\n' ' ')"; done
