#!/bin/bash
# voff.sh <law bin> <verified bin> <scratch> : R11V405_OFF (and each refinement's own switch on its group)
# on the verified binary must give the law binary's bytes and exit code on every case dir.
H=$(cd $(dirname $0)/.. && pwd); L=$1; V=$2; W=$3; mkdir -p $W; n=0; ok=0; own=0
declare -A SW=([VH]=R11V405_HSWCTX_OFF [VU]=R11V405_UNBSIZE_OFF)
while read -r d <&3; do c=$(dirname $d); g=$(basename $(dirname $c)); key=${g}_$(basename $c)
  rm -f $W/$key.L $W/$key.O $W/$key.S
  (cd $c && $L dut.sv --single-unit --nobuiltin -o $W/$key.L >/dev/null 2>&1 </dev/null); rl=$?
  (cd $c && R11V405_OFF=1 $V dut.sv --single-unit --nobuiltin -o $W/$key.O >/dev/null 2>&1 </dev/null); ro=$?
  if cmp -s $W/$key.L $W/$key.O && [ $rl = $ro ]; then ok=$((ok+1)); else echo "V-OFF-MOVES $g/$(basename $c)"; fi
  s=${SW[$g]:-R11V405_NONE}
  (cd $c && env $s=1 $V dut.sv --single-unit --nobuiltin -o $W/$key.S >/dev/null 2>&1 </dev/null); rs=$?
  if [ -n "${SW[$g]}" ]; then if cmp -s $W/$key.L $W/$key.S && [ $rl = $rs ]; then own=$((own+1)); else echo "OWN-V-SWITCH-MOVES $g/$(basename $c)"; fi; fi
  n=$((n+1))
done 3< <(find $H/cases $H/../r11u405repro/cases -name dut.sv | sort)
echo "cases=$n R11V405_OFF-gives-law=$ok own-refinement-switch-gives-law(VH,VU)=$own"
