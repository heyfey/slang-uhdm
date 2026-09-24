#!/bin/bash
# switches.sh <case dir>...  -> per case: pristine vs law bytes, R11U130_OFF=1 vs pristine bytes, and per switch
# whether turning ONLY that switch off changes the law bytes (the law's attribution on that case)
source /tmp/r11u130_env.sh
SW="DEFNETLOC WILDSPAN CLSARGNET NETSIGN PVPARAM SUSIGN IFSUKW REDEFLINE INCNOTEXT GVTSFILE"
for d in "$@"; do
  d=$(realpath $d); w=/tmp/r11u130_sw/$(echo "$d" | md5sum | cut -c1-12); mkdir -p $w
  run(){ rm -f $w/$1.uhdm; (cd $d && env $2 /tmp/r11u130_bin/$3 dut.sv --single-unit --nobuiltin -o $w/$1.uhdm >/dev/null 2>&1); md5sum < $w/$1.uhdm | cut -c1-12; }
  p=$(run P "X=1" pris.bin); l=$(run L "X=1" law.bin); off=$(run O "R11U130_OFF=1" law.bin)
  moved=$([ "$p" = "$l" ] && echo same || echo MOVED); offok=$([ "$off" = "$p" ] && echo off=pristine || echo OFF-DIFFERS)
  by=""; for s in $SW; do x=$(run S_$s "R11U130_${s}_OFF=1" law.bin); [ "$x" != "$l" ] && by="$by $s"; done
  echo "$(basename $(dirname $d))/$(basename $d)	$moved	$offok	laws:${by:- none}"
done
