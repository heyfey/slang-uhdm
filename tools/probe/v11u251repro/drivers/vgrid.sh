#!/bin/bash
# vgrid.sh <outfile> [group...]: every case under ../cases in both views on pristine, law, law + R11U251_OFF and
# law + its group's own switch (RN: REGNET, IN: IFDYNVAR and IFDYNNT, SC: PPSTREND, AI: CLSTDIDXLOC,
# RT: RETTWINALIAS, BP: BINDPORTREF, EB: CLSENUMBASE with NB=1, the builtin mode). One case.sh line per run (rc included).
[ -n "$FENCED" ] && [ -n "$B" ] || { echo "vgrid.sh: source drivers/env.sh" >&2; exit 2; }
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
groups=${*:-"RN IN SC AI RT BP EB"}
for g in $groups; do
  case $g in RN) SW="R11U251_REGNET_OFF";; IN) SW="R11U251_IFDYNVAR_OFF R11U251_IFDYNNT_OFF";; SC) SW=R11U251_PPSTREND_OFF;;
    AI) SW=R11U251_CLSTDIDXLOC_OFF;; RT) SW=R11U251_RETTWINALIAS_OFF;; BP) SW=R11U251_BINDPORTREF_OFF;; EB) SW=R11U251_CLSENUMBASE_OFF;; esac
  nb=0; [ $g = EB ] && nb=1
  for c in $(cd $H && ls -d cases/$g/* | sort); do
    for el in 0 1; do
      NB=$nb EL=$el $H/drivers/case.sh $H/$c pristine $B/pristine.bin >> $out
      NB=$nb EL=$el $H/drivers/case.sh $H/$c law $B/law.bin >> $out
      NB=$nb EL=$el $H/drivers/case.sh $H/$c lawOFF $B/law.bin R11U251_OFF=1 >> $out
      for s in $SW; do NB=$nb EL=$el $H/drivers/case.sh $H/$c "law-$s" $B/law.bin $s=1 >> $out; done
      NB=$nb EL=$el $H/drivers/case.sh $H/$c trace $B/law.bin R11U251_TRACE=$S/tr/$(echo $c | tr / _)_$el >/dev/null 2>&1 </dev/null
    done
  done
done
