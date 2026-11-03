#!/bin/bash
# probedump.sh <law probe wd> <control probe wd> <list>: per probe database, uhdm-dump both
# sides, strip directories from every path, compare; prints SAME/DIFF counts and the
# DIFF names, then a negative control (each dump against the next case's control dump).
source ${ENVFILE:-/tmp/v11u479_env.sh} || exit 1
A=$1; B=$2; L=$3; s=0; d=0; neg=0; prev=""
while IFS= read -r p <&3; do
  x=$($UHDM_DUMP "$A/$p" 2>/dev/null | sed -E '1d; s#[^ ,:]*/##g' | md5sum)
  y=$($UHDM_DUMP "$B/$p" 2>/dev/null | sed -E '1d; s#[^ ,:]*/##g' | md5sum)
  if [ "$x" = "$y" ]; then s=$((s+1)); else d=$((d+1)); echo "DIFF $p"; fi
  [ -n "$prev" ] && [ "$x" != "$prev" ] && neg=$((neg+1)); prev=$y
done 3< "$L"
echo "SAME=$s DIFF=$d negative-control(differs from the previous case's control dump)=$neg"
