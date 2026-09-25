#!/bin/bash
# swcheck.sh <out.tsv> <casedir>...: per case, the pristine / law / all-off / one-switch-off databases
# (golden-free: bytes only). Columns: case, law==pristine?, alloff==pristine?, then the switches whose
# single OFF returns the pristine bytes. Binaries: $PRIS, $LAW. Scratch: $SW (default /tmp/r11u146_sw).
OUT=$1; shift
PRIS=${PRIS:-/tmp/r11u146_bin/pris.bin}; LAW=${LAW:-/tmp/r11u146_bin/law.final.bin}; SW=${SW:-/tmp/r11u146_sw}
SWS="R11U148_E_OFF R11U148_E2_OFF R11U148_I_OFF R11U146_MODARRBOUND_OFF R11U146_PORTINIT_OFF R11U146_TPSTRUCTKW_OFF R11U146_TPCALHS_OFF R11U146_CLSTDPKG_OFF R11U146_CASTKEYFILE_OFF R11U146_ESCCOL_OFF R11U146_PORTEXPRLOC_OFF R11U146_PORTEXPRDEF_OFF R11U146_UCPLOC_OFF R11U146_UCPIF_OFF R11U146_PATHBASE_OFF R11U146_TFARGTD_OFF"
printf 'case\tlaw_moves\talloff_is_pristine\towners\n' > $OUT
for c in "$@"; do
  c=$(realpath $c); rel=$(echo $c | sed 's#.*/grid/##; s#.*/cases/##'); w=$SW/$rel; mkdir -p $w
  run() { rm -f $w/$1.uhdm; (cd $c && env $2 $3 dut.sv --single-unit --nobuiltin -o $w/$1.uhdm > /dev/null 2>&1); }
  run P "" $PRIS; run L "" $LAW; run O "R11U146_OFF=1" $LAW
  mv=$(cmp -s $w/P.uhdm $w/L.uhdm && echo no || echo MOVES)
  ao=$(cmp -s $w/P.uhdm $w/O.uhdm && echo yes || echo NO)
  own=""
  if [ $mv = MOVES ]; then
    for s in $SWS; do run S "$s=1" $LAW; cmp -s $w/P.uhdm $w/S.uhdm && own="$own $s"; done
  fi
  printf '%s\t%s\t%s\t%s\n' "$rel" $mv $ao "${own# }" >> $OUT
done
