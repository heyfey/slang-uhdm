#!/bin/bash
# usage: census.sh <list> <out.tsv>; runs pristine, law and verified on each source (its directory copied
# to scratch), records rc + md5 per binary and the law / verified trace firing counts
P=/tmp/v11u443_bin/pristine; L=/tmp/v11u443_bin/law; V=/tmp/v11u443_bin/ver; W=/tmp/v11u443_cen
for b in $P $L $V; do [ -x $b ] || exit 2; done
: > $2
while read -u 3 f; do
  d=$W/$(echo ${f#/tmp/wt_v11u443/tools/probe/} | tr / _); rm -rf $d; mkdir -p $d; cp $(dirname $f)/* $d/ 2>/dev/null
  b=$(basename $f)
  (cd $d && timeout 120 $P $b --single-unit --nobuiltin -o p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $d && R11U443_TRACE=$d/trl timeout 120 $L $b --single-unit --nobuiltin -o l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  (cd $d && R11U443_TRACE=$d/trv timeout 120 $V $b --single-unit --nobuiltin -o v.uhdm >/dev/null 2>&1 </dev/null); rv=$?
  mp=$(md5sum < $d/p.uhdm 2>/dev/null | cut -c1-8); ml=$(md5sum < $d/l.uhdm 2>/dev/null | cut -c1-8); mv=$(md5sum < $d/v.uhdm 2>/dev/null | cut -c1-8)
  fl=$(cat $d/trl/* 2>/dev/null | grep -vc '^OUT'); fv=$(cat $d/trv/* 2>/dev/null | grep -c 'progStructNetElemKeeps443v')
  echo "${f#/tmp/wt_v11u443/tools/probe/}	$rp	$rl	$rv	$mp	$ml	$mv	$fl	$fv" >> $2
done 3< $1
