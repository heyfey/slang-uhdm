#!/bin/bash
# sw.sh <case dir>: md5 of our db under pristine, fix1, and fix1 with each switch
d=$1; T=/tmp/v11u147_sw/$(echo $d | md5sum | cut -c1-12); mkdir -p $T
SW="NONE R11U147_OFF R11U151_OFF R11U147_IFTRAILIDX_OFF R11U147_VSIPSBASE_OFF R11U147_LVIDXBS_OFF R11U147_NESTDEFLOC_OFF R11U147_GCAUSESITE_OFF R11U147_FIRSTPOS_OFF R11U147_ENUMCLONE_OFF R11U147_ENUMQSPAN_OFF R11V147_GCABARE_OFF R11U151_D2_OFF R11U151_ARR_OFF R11U151_ARRNB_OFF R11U151_G_OFF R11U151_G2_OFF R11U151_D_OFF R11U151_DCAST_OFF R11U151_C3_OFF"
cd $d
rm -f $T/p.uhdm; /tmp/v11u147_bin/pris dut.sv --single-unit --nobuiltin -o $T/p.uhdm >/dev/null 2>&1; line="$d PRIS=$(md5sum < $T/p.uhdm 2>/dev/null | cut -c1-8)"
for s in $SW; do rm -f $T/s.uhdm; if [ $s = NONE ]; then /tmp/v11u147_bin/fix1 dut.sv --single-unit --nobuiltin -o $T/s.uhdm >/dev/null 2>&1; else env $s=1 /tmp/v11u147_bin/fix1 dut.sv --single-unit --nobuiltin -o $T/s.uhdm >/dev/null 2>&1; fi
  line="$line $s=$(md5sum < $T/s.uhdm 2>/dev/null | cut -c1-8)"; done
echo "$line"; rm -rf $T
