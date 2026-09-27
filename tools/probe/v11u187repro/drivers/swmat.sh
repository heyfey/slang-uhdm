#!/bin/bash
# swmat.sh <casedir> <tag>: per switch, does the law binary with the switch write pristine bytes / law bytes / other
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
echo "$1" | grep -qP "$FENCERE" && { echo FENCE; exit 4; }
d=$1; t=$2; w=/tmp/v11u187_sm/$t; mkdir -p $w
run(){ rm -f $w/$1.uhdm; (cd $d && env $2 timeout 300 $3 dut.sv --single-unit --nobuiltin -o $w/$1.uhdm >/dev/null 2>&1 </dev/null); md5sum < $w/$1.uhdm 2>/dev/null | cut -c1-8; }
P=$(run pris "" $PRIS); L=$(run law "" $LAW)
rm -rf $w/tr; mkdir -p $w/tr; (cd $d && R11U183_TRACE=$w/tr R11U187_TRACE=$w/tr $LAW dut.sv --single-unit --nobuiltin -o $w/x.uhdm >/dev/null 2>&1 </dev/null)
fires=$(cat $w/tr/* 2>/dev/null | grep -v '^OUT' | sort -u | tr '\n' ',')
out="$t P=$P L=$L fires=$fires"
for s in R11U183_RANGEFILE_OFF R11U183_FEIDX_OFF R11U183_TSSPAN_OFF R11U183_IFARR_OFF R11U183_PATHSPAN_OFF R11U183_CLONELV_OFF R11U183_UVMCOPY_OFF R11U183_DEPTH_OFF R11U183_OFF R11U187_TRAILCALL_OFF R11U187_TRAILSEL_OFF R11U187_OFF; do
  m=$(run s "$s=1" $LAW); c=o; [ "$m" = "$P" ] && c=P; [ "$m" = "$L" ] && c=L; [ "$P" = "$L" ] && c=eq
  out="$out ${s#R11U18}:$c"
done
echo "$out"
