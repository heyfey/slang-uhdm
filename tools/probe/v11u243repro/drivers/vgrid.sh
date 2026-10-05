#!/bin/bash
# vgrid.sh <outfile> [configs...]: every case under cases/ in both views on the named configurations
# (pristine law lawOFF and law-<SWITCH>); one case.sh line per run, exit code included. Source drivers/env.sh first.
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vgrid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
CF=${*:-pristine law lawOFF}
run1() { c=$1; el=$2; for cf in $CF; do
  case $cf in
    pristine) EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine ;;
    law) EL=$el $H/drivers/case.sh $H/$c law ${LAWBIN:-$B/law} ;;
    lawOFF) EL=$el $H/drivers/case.sh $H/$c lawOFF ${LAWBIN:-$B/law} R11U243_OFF=1 ;;
    fix) EL=$el $H/drivers/case.sh $H/$c fix $B/fix ;;
    fixOFF) EL=$el $H/drivers/case.sh $H/$c fixOFF $B/fix R11V243_OFF=1 ;;
    fix-*) EL=$el $H/drivers/case.sh $H/$c $cf $B/fix ${cf#fix-}=1 ;;
    law-*) EL=$el $H/drivers/case.sh $H/$c $cf ${LAWBIN:-$B/law} ${cf#law-}=1 ;;
  esac; done; }
export -f run1; export H CF
(cd $H && ls -d cases/*/* | sort) | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P 2 -L 1 bash -c 'run1 $0 $1' >> $out
sort -o $out $out
