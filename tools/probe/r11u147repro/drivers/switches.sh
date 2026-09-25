#!/bin/bash
# switches.sh <law bin> <pristine bin> <case dirs...>: every case under the law binary with
# R11U147_OFF=1 (which also drops the landed r11u151 laws) and with each single switch off; compares each database with pristine's
# and with the law's (cmp).  Prints per switch the cases whose bytes differ from the law
# run (what the switch owns) and, for the master switch, the cases that differ from pristine.
LAW=$1; PRI=$2; shift 2
SW=${SW:-"R11U147_IFTRAILIDX_OFF R11U147_VSIPSBASE_OFF R11U147_LVIDXBS_OFF R11U147_NESTDEFLOC_OFF R11U147_GCAUSESITE_OFF R11U147_FIRSTPOS_OFF R11U147_ENUMCLONE_OFF R11U147_ENUMQSPAN_OFF R11U151_D2_OFF R11U151_ARR_OFF R11U151_ARRNB_OFF R11U151_G_OFF R11U151_G2_OFF R11U151_D_OFF R11U151_DCAST_OFF R11U151_C3_OFF"}
T=/tmp/r11u147_sw; rm -rf $T; mkdir -p $T
run(){ # dir tag envassign...
  local d=$1 tag=$2; shift 2; local o=$T/$(echo $d | md5sum | cut -c1-10).$tag.uhdm; rm -f $o
  (cd $d && env "$@" $BIN dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1); echo $o; }
declare -A owned; lawdiff=0; offdiff=""
for d in "$@"; do d=$(cd $d && pwd)
  BIN=$PRI; p=$(run $d pri X=1); BIN=$LAW; l=$(run $d law X=1); a=$(run $d all R11U147_OFF=1)
  cmp -s $p $l || lawdiff=$((lawdiff+1))
  cmp -s $p $a || offdiff="$offdiff $(basename $(dirname $d))/$(basename $d)"
  for s in $SW; do o=$(run $d $s $s=1); cmp -s $o $l || owned[$s]="${owned[$s]} $(basename $(dirname $d))/$(basename $d)"; done
done
echo "cases=$# law_differs_from_pristine=$lawdiff"
echo "R11U147_OFF=1 differs from pristine on:${offdiff:- none}"
for s in $SW; do echo "$s owns:${owned[$s]:- none}"; done
