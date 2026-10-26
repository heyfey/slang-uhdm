#!/bin/bash
# usage: switch.sh <pristine bin> <law bin> "<VAR=1 ...>" <case dir>...
# prints, per case, whether the law binary under the given switches writes
# pristine's bytes (the -o path is the same for both runs).
P=$1; L=$2; SW=$3; shift 3
T=/tmp/r11u435_sw; mkdir -p $T
for c in "$@"; do
  c=$(readlink -f $c)
  rm -f $T/a.uhdm $T/b.uhdm
  (cd $c && $P dut.sv --single-unit --nobuiltin -o $T/x.uhdm >/dev/null 2>&1 </dev/null; echo $? > $T/ra; mv $T/x.uhdm $T/a.uhdm 2>/dev/null)
  (cd $c && env $SW $L dut.sv --single-unit --nobuiltin -o $T/x.uhdm >/dev/null 2>&1 </dev/null; echo $? > $T/rb; mv $T/x.uhdm $T/b.uhdm 2>/dev/null)
  if cmp -s $T/a.uhdm $T/b.uhdm && cmp -s $T/ra $T/rb; then r=same; else r=DIFF; fi
  echo "$(basename $(dirname $c))/$(basename $c) $r"
done
