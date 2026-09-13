#!/bin/bash
# r11v11u8 independent a-priori predictor: every database in WD whose dump
# holds a string constant value starting with a space or tab. The law can only
# SHORTEN such a value, so a database absent from this list cannot move.
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
WD=${1:?workdir}
n=0; hit=0
for f in $(find "$WD" -name 'slang.uhdm' | sort); do
  n=$((n+1))
  if $D "$f" 2>/dev/null | grep -qE '\|STRING:[ 	]'; then
    hit=$((hit+1)); echo "LEAD $(echo "$f" | sed "s|$WD/||; s|/slang.uhdm||")"
  fi
done
echo "SCANNED $n FLAGGED $hit"
