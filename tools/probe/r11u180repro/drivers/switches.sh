#!/bin/bash
# switches.sh <law binary> <out.txt> : each R11U180_*_OFF switch alone over every case: which cases' databases differ
# from the all-on database (the law's own cases), and whether each such database equals the pristine one.
set -u; . /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
L=$1; OUT=$2; R=/tmp/wt_r11u180/tools/probe/r11u180repro; : > $OUT
SW="ENUMIMP ENUMIMPHDR TPUSE TPFORMAL TPCHAIN TPQUAL MODAGGCLONE PKGAGGCLONE IFACETDORDER PORTINTREDECL AGGSWITCH"
cases=$(cd $R && find cases -name dut.sv | xargs -n1 dirname | sort)
for c in $cases; do (cd $R/$c && $L $( [ -f files ] && cat files || echo dut.sv) --single-unit --nobuiltin -o /tmp/r11u180_scr/sw_on.$(echo $c | tr / _).uhdm >/dev/null 2>&1); done
for sw in $SW; do
  moved=""
  for c in $cases; do
    k=$(echo $c | tr / _); f=/tmp/r11u180_scr/sw_$sw.$k.uhdm; rm -f $f
    (cd $R/$c && env R11U180_${sw}_OFF=1 $L $( [ -f files ] && cat files || echo dut.sv) --single-unit --nobuiltin -o $f >/dev/null 2>&1)
    cmp -s $f /tmp/r11u180_scr/sw_on.$k.uhdm || moved="$moved ${c#cases/}"
  done
  echo "R11U180_${sw}_OFF moves:${moved:- (none)}" >> $OUT
done
cat $OUT
