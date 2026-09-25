#!/bin/bash
# swcheck_grid.sh <law-binary> [gridroot]: switch attribution on the grid.  For every case: the law binary with
# R11U151_OFF=1, and with the case's own class switch alone, must write the pristine bytes (<gridroot>/<class>/<case>/pris.uhdm);
# the law binary with no switch is the positive control (MOVED where the law acts).
B=$1; R=${2:-/tmp/r11u151_g}; D=$(cd "$(dirname "$0")" && pwd); C=$D/../cases
declare -A SW=([ARR]=R11U151_ARR_OFF [C3]=R11U151_C3_OFF [D2]=R11U151_D2_OFF [D]=R11U151_D_OFF [DEFPAT]=R11U151_DEFPAT_OFF [G]=R11U151_G_OFF [G2]=R11U151_G_OFF)
for c in $(find $C -name dut.sv | sort); do
  d=$(dirname $c); cls=$(basename $(dirname $d)); n=$(basename $d); w=$R/$cls/$n; out=""
  for mode in none all class; do
    o=/tmp/r11u151_swchk.uhdm; rm -f $o
    case $mode in
      none)  (cd $d && $B dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1) ;;
      all)   (cd $d && env R11U151_OFF=1 $B dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1) ;;
      class) (cd $d && env ${SW[$cls]}=1 $B dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1) ;;
    esac
    cmp -s $o $w/pris.uhdm && out="$out $mode=PRISTINE" || out="$out $mode=MOVED"
  done
  echo "$cls/$n$out"
done
