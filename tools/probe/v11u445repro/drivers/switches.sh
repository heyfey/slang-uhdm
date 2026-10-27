#!/bin/bash
# usage: switches.sh <out.tsv> <griddir>... ; for each grid dir: md5 of law under R11U445_OFF and under each single law switch vs pris
L=/tmp/v11u445_bin/law; [ -x "$L" ] || exit 2
out=$1; shift; : > $out
for d in "$@"; do
  p=$(md5sum < $d/out_pris.uhdm | cut -c1-8); l=$(md5sum < $d/out_law.uhdm | cut -c1-8)
  line="$(basename $d)	pris=$p law=$l"
  for sw in R11U445_OFF R11U445_SHADOWBLK_OFF R11U445_MODPARAM_OFF R11U445_PARAMREAD_OFF R11U445_PARAMNOSHADOW_OFF R11U445_IFACELVDECL_OFF R11U445_PKGLVDECL_OFF; do
    rm -f $d/out_sw.uhdm
    (cd $d && env $sw=1 $L dut.sv --single-unit --nobuiltin -o out_sw.uhdm >/dev/null 2>&1 </dev/null); rc=$?
    m=$(md5sum < $d/out_sw.uhdm | cut -c1-8)
    t=other; [ "$m" = "$p" ] && t=P; [ "$m" = "$l" ] && t=L; [ "$p" = "$l" ] && t=PL
    line="$line	${sw#R11U445_}:rc=$rc:$t"
  done
  echo "$line" >> $out
done
