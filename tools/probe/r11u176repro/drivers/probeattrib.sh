#!/bin/bash
# probeattrib.sh <movers.txt> <out.txt> : for every probe byte mover (the <case>.uhdm names of the gate sweep), run the
# final binary on tests/probe/<case>/dut.sv with each switch alone and with R11U176_TRACE=1; print the switches whose
# drop restores the pristine sweep's database and the firing trace.  (check_probe's arguments: dut.sv --single-unit
# --nobuiltin.)  The probe set holds no fenced test.
set -u; SW="R11U175_FSPAN_OFF R11U176_CASTCLONE_OFF R11U176_PROGLCLOC_OFF R11U176_PROGMPDEF_OFF R11U176_GENMPLOC_OFF R11U176_GENPLAINLOC_OFF R11U176_GENPLAINVARS_OFF R11U176_PROGVIEW_OFF R11U176_QUALFORMAL_OFF R11U176_CLSMETHOD_OFF R11U176_DEFTOPSPLIT_OFF R11U176_TDKEY_OFF R11U176_TDTIE_OFF R11U176_UDPLV_OFF R11U176_ELSEBEGIN_OFF R11U176_GENARR_OFF"
one() { f=$1; c=${f%.uhdm}; dir=/tmp/wt_r11u176/tests/probe/${c//__//}; T=/tmp/r11u176_scratch/pa/$c; mkdir -p $T
  (cd $dir && R11U176_TRACE=1 /tmp/r11u176_bin/final4.bin dut.sv --single-unit --nobuiltin -o $T/f.uhdm > /dev/null 2> $T/trace </dev/null)
  tr=$(grep -o '^R11U176 [A-Z]*' $T/trace | sort -u | awk '{printf "%s ", $2}')
  r=""; for s in $SW; do rm -f $T/s.uhdm; (cd $dir && env $s=1 /tmp/r11u176_bin/final4.bin dut.sv --single-unit --nobuiltin -o $T/s.uhdm > /dev/null 2>&1 </dev/null); cmp -s $T/s.uhdm /tmp/r11u176_swP/probe/$f && r="$r $s"; done
  echo "$c trace: ${tr:-none} restores:${r:- none}"; }
export -f one; export SW
xargs -P 4 -I{} bash -c 'one {}' < $1 | sort > $2
