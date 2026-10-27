#!/bin/bash
# usage: census.sh <list> <out.tsv>; runs pristine and law3 on each dut, records rc + md5
P=/tmp/r11u443_bin/pristine; L=/tmp/r11u443_bin/law3; W=/tmp/r11u443_cen
[ -x $P ] && [ -x $L ] || exit 2
: > $2
while read -u 3 f; do
  d=$W/$(echo ${f#/tmp/wt_r11u443/tools/probe/} | tr / _); mkdir -p $d; cp $(dirname $f)/* $d/ 2>/dev/null
  b=$(basename $f)
  rm -f $d/p.uhdm $d/l.uhdm
  (cd $d && timeout 120 $P $b --single-unit --nobuiltin -o p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $d && R11U443_TRACE=$d/tr timeout 120 $L $b --single-unit --nobuiltin -o l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  mp=$(md5sum < $d/p.uhdm 2>/dev/null | cut -c1-8); ml=$(md5sum < $d/l.uhdm 2>/dev/null | cut -c1-8)
  fi=$(cat $d/tr/* 2>/dev/null | grep -vc '^OUT')
  echo "$f	$rp	$rl	$mp	$ml	$fi" >> $2
done 3< $1
