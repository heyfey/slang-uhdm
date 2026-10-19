#!/bin/bash
# for each case: V vs L bytes; V with R11V407_OFF vs L bytes; each fix switch alone
L=/tmp/v11u407_bin/law.bin; V=/tmp/v11u407_bin/ver.bin; W=/tmp/v11u407_fo; mkdir -p $W
same=0; diffc=0; offok=0; n=0
for d in $(find /tmp/wt_v11u407/tools/probe/r11u407repro/cases /tmp/wt_v11u407/tools/probe/v11u407repro/cases -name dut.sv | sort); do c=$(dirname $d); k=$(basename $(dirname $c))_$(basename $c); n=$((n+1))
 for t in L V O; do rm -f $W/$k.$t.uhdm; done
 (cd $c; $L dut.sv --single-unit --nobuiltin -o $W/$k.L.uhdm >/dev/null 2>&1; echo $? > $W/$k.L.rc
  $V dut.sv --single-unit --nobuiltin -o $W/$k.V.uhdm >/dev/null 2>&1; echo $? > $W/$k.V.rc
  R11V407_OFF=1 $V dut.sv --single-unit --nobuiltin -o $W/$k.O.uhdm >/dev/null 2>&1; echo $? > $W/$k.O.rc)
 if cmp -s $W/$k.L.uhdm $W/$k.V.uhdm; then same=$((same+1)); else diffc=$((diffc+1)); mv=""
   for s in R11V407_LVPROG_OFF R11V407_LVPARAM_OFF R11V407_SEQEVGEN_OFF R11V407_BSTARGET_OFF; do rm -f $W/$k.S.uhdm; (cd $c; env $s=1 $V dut.sv --single-unit --nobuiltin -o $W/$k.S.uhdm >/dev/null 2>&1); cmp -s $W/$k.S.uhdm $W/$k.L.uhdm && mv="$mv $s"; done
   echo "V-MOVES $k restored-by:$mv"; fi
 cmp -s $W/$k.L.uhdm $W/$k.O.uhdm && cmp -s $W/$k.L.rc $W/$k.O.rc && offok=$((offok+1))
done
echo "cases=$n V==L:$same V!=L:$diffc R11V407_OFF->law:$offok"
