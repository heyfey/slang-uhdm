#!/bin/bash
# v11u202: each refinement switch alone (and R11V202_OFF / R11U202_OFF) over case dirs.  For every case: the v2 binary
# plain with R11U202_TRACE, then with one switch set; a byte move must come with that switch's own law in the trace.
# R11V202_OFF=1 must write the law binary's bytes, R11U202_OFF=1 the pristine binary's.   usage: switches.sh <case dir>...
source "$(dirname "$0")/env.sh" || exit 3
declare -A LAW=([R11V202_PORTIMPL_OFF]=portPackedBareImplicitTruncates202v [R11V202_TDRETVAR_OFF]=classTdRetVarKeepsWrittenLoc202v
  [R11V202_IMPLCMT_OFF]=implicitTsEndAfterLineComment202v [R11V202_IMPLCR_OFF]=implicitTsEndSkipsCarriageReturn202v
  [R11V202_VALSPECDEF_OFF]=modSpecValueArgDefViewMultiArg202v)
T=/tmp/v11u202_switches; rm -rf $T; mkdir -p $T; n=0; bad=0
for d in "$@"; do
  echo "$d" | grep -Pq "$FENCERE" && { echo "fenced refused"; exit 3; }
  t=$T/$(echo $d | md5sum | cut -c1-12); mkdir -p $t; n=$((n+1))
  run() { rm -f $t/$1.uhdm; (cd $d && env $2 $VB/$3.bin dut.sv --single-unit --nobuiltin -o $t/$1.uhdm >/dev/null 2>&1); }
  run v2 "R11U202_TRACE=$t" v2; run law "" law; run pris "" pris
  run voff "R11V202_OFF=1" v2; cmp -s $t/voff.uhdm $t/law.uhdm || { echo "R11V202_OFF!=law $d"; bad=$((bad+1)); }
  run uoff "R11U202_OFF=1" v2; cmp -s $t/uoff.uhdm $t/pris.uhdm || { echo "R11U202_OFF!=pris $d"; bad=$((bad+1)); }
  for sw in "${!LAW[@]}"; do run sw "$sw=1" v2
    if ! cmp -s $t/sw.uhdm $t/v2.uhdm; then
      if cat $t/*.202 2>/dev/null | grep -q "^${LAW[$sw]} "; then echo "MOVED-TRACED $sw $d"; else echo "MOVED-UNTRACED $sw $d"; bad=$((bad+1)); fi; fi
  done
done
echo "cases=$n bad=$bad"
