#!/bin/bash
# switches.sh <law bin> <pristine bin> <case root>: master switch restores pristine bytes on every
# case; each single switch moves (vs the law binary) only the cases listed. Measurement only (r11u140).
L=$1; P=$2; ROOT=$3; O=/tmp/r11u140_x/sw; rm -rf $O; mkdir -p $O
SW="SYSUNARY STREAMBRACE LVIDX LVTRAIL FEFILE PATOPSPAN MULTIDECL LHSARRTS PKGREFMD PKGTDCAST DEFFILL REPLCNTFILE"
cases=$(cd $ROOT && find . -name dut.sv | sed 's#^\./##; s#/dut.sv##' | sort)
run(){ # tag envassign case
  local k=$(echo $3 | tr / _); rm -f $O/$k.$1.uhdm
  (cd $ROOT/$3 && env $2 $4 dut.sv --single-unit --nobuiltin -o $O/$k.$1.uhdm </dev/null >/dev/null 2>&1)
}
same=0; diff=0; lawmv=0
for c in $cases; do
  k=$(echo $c | tr / _)
  run P "X=1" $c $P; run L "X=1" $c $L; run M "R11U140_OFF=1" $c $L
  if cmp -s $O/$k.P.uhdm $O/$k.M.uhdm; then same=$((same+1)); else diff=$((diff+1)); echo "MASTER-DIFF $c"; fi
  cmp -s $O/$k.P.uhdm $O/$k.L.uhdm || lawmv=$((lawmv+1))
done
echo "MASTER: R11U140_OFF=1 byte-identical to pristine on $same of $((same+diff)) cases; law binary differs from pristine on $lawmv"
for s in $SW; do
  mv=""
  for c in $cases; do
    k=$(echo $c | tr / _); run S "R11U140_${s}_OFF=1" $c $L
    cmp -s $O/$k.S.uhdm $O/$k.L.uhdm || mv="$mv $c"
  done
  echo "SWITCH R11U140_${s}_OFF moves:$mv"
done
