#!/bin/bash
# heads.sh <wd> <outdir> : strictcmp --max 30 on every CMP_EQUAL strict-differ row; writes <outdir>/<corpus>/<mode>/<test>.out
wd=$1; out=$2
for c in surelog uhdm2rtlil; do
  awk -F, -v c=$c 'NR>1 && $3=="CMP_EQUAL" && $6!="equal"{print c" "$2" "$1}' $wd/$c.csv
done | while read c m t; do
  d=$(ls -d $wd/$c/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] || continue
  echo "$c $m $t $d"
done > $out.jobs
mkdir -p $out
cat $out.jobs | xargs -P ${P:-2} -L1 bash -c 'c=$0; m=$1; t=$2; d=$3; mkdir -p '$out'/$c/$m; G=$(grep -o "/home[^)]*" $d/cmds.txt | head -1)/golden.uhdm; [ -f $G ] || G=$d/slpp_all/surelog.uhdm; /tmp/r11u125_bin/strictcmp.bin --max 30 $G $d/slang.uhdm > '$out'/$c/$m/$t.out 2>&1'
