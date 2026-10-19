#!/bin/bash
# grid.sh <pristine bin> <law bin> <scratch dir>
# Per case dir: golden (Surelog -parse -nobuiltin -nocache -sv dut.sv), both
# binaries (dut.sv --single-unit --nobuiltin), uhdm-cmp line count and the
# uhdm-strictcmp verdict, exit codes; then each group's own switch(es) and
# R11U409_OFF on the law binary must give pristine's bytes and exit code.
H=$(cd $(dirname $0)/.. && pwd); . $H/drivers/env.sh
P=$1; L=$2; W=$3; mkdir -p $W
declare -A SW=([IM]=R11U409_TDPARAMCLONE_OFF [EW]=R11U409_DEFIMPARITH_OFF [EN]=R11U409_IMPENUMSIZE_OFF [OE]=R11U409_OOBEVTRIG_OFF [SP]=R11U409_STREAMPAREN_OFF [GV]=R11U409_GATEGENVAR_OFF)
verdict() { # golden ours -> "cmp=<n> <strict verdict>"
  local n=$($UHDM_CMP $1 $2 2>&1 | wc -l); echo "cmp=$n $($SC $1 $2 2>&1 | tail -1)"; }
n=0; sw=0; off=0
while read -r d <&3; do
  c=$(dirname $d); g=$(basename $(dirname $c)); k=$g/$(basename $c); key=$(echo $k | tr / _)
  mkdir -p $W/g_$key; ( cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $W/g_$key >/dev/null 2>&1 </dev/null )
  G=$W/g_$key/slpp_all/surelog.uhdm
  for b in P L; do bin=${!b}; rm -f $W/$key.$b.uhdm
    ( cd $c && $bin dut.sv --single-unit --nobuiltin -o $W/$key.$b.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.$b.rc; done
  echo "$k pristine rc=$(cat $W/$key.P.rc) $(verdict $G $W/$key.P.uhdm) | law rc=$(cat $W/$key.L.rc) $(verdict $G $W/$key.L.uhdm)"
  e=""; for s in ${SW[$g]}; do e="$e $s=1"; done
  rm -f $W/$key.S.uhdm; ( cd $c && env $e $L dut.sv --single-unit --nobuiltin -o $W/$key.S.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.S.rc
  if cmp -s $W/$key.P.uhdm $W/$key.S.uhdm && cmp -s $W/$key.P.rc $W/$key.S.rc; then sw=$((sw+1)); else echo "  OWN-SWITCH-MOVES $k [$e]"; fi
  rm -f $W/$key.O.uhdm; ( cd $c && R11U409_OFF=1 $L dut.sv --single-unit --nobuiltin -o $W/$key.O.uhdm >/dev/null 2>&1 </dev/null ); echo $? > $W/$key.O.rc
  if cmp -s $W/$key.P.uhdm $W/$key.O.uhdm && cmp -s $W/$key.P.rc $W/$key.O.rc; then off=$((off+1)); else echo "  PASS-OFF-MOVES $k"; fi
  n=$((n+1))
done 3< <(find $H/cases -name dut.sv | sort)
echo "cases=$n own-switch-restores-pristine=$sw R11U409_OFF-restores-pristine=$off"
