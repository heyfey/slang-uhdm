#!/bin/bash
# grid.sh <law binary> <tag> [ENV=VAL ...]: every case dir, pristine vs law, with the law's trace
D=$(cd $(dirname $0)/.. && pwd); B=$1; t=$2; shift 2
P=/tmp/r11u449_bin/pristine
for c in $(cd $D && ls -d cases/*/* | sort); do
  k=$(echo $c | tr / _); tr=/tmp/r11u449_tr/$t/$k; rm -rf $tr; mkdir -p $tr
  p=$(bash $D/drivers/run1.sh $D/$c $P pris | sed 's/r11u449repro_cases_//')
  l=$(bash $D/drivers/run1.sh $D/$c $B $t R11U449_TRACE=$tr "$@" | sed 's/r11u449repro_cases_//')
  echo "$p || ${l#* }  tr=$(cat $tr/* 2>/dev/null | awk '{print $1}' | sort | uniq -c | awk '{printf "%s:%s ", $2, $1}')"
done
