#!/bin/bash
# (r11u217) namecensus.sh <off wd> <on wd> <corpus> <mode> <row>...: the raw full-name census the strict walk cannot see
# (it canonicalises full names inside a typespec copy): the multiset of every vpiFullName line of the uhdm-dump of golden,
# the OFF database and the ON database; lost = names golden and OFF share that ON lacks, gained = the reverse.
# Refuses a fenced row by word boundary (fail-closed on $FENCED, drivers/env.sh).
source "$(dirname "$0")/env.sh" || exit 2
A=$1; B=$2; C=$3; M=$4; shift 4; T=/tmp/r11u217_names; mkdir -p $T
for R in "$@"; do
  echo "$R" | grep -Pq "$FENCE_RE" && { echo "$R fenced: refused"; continue; }
  da=$(ls -d $A/$C/$M/$R-* | head -1); db=$(ls -d $B/$C/$M/$R-* | head -1)
  g=$(grep -o 'golden cache [a-z]* [^)]*' $db/cmds.txt | awk '{print $4}')/golden.uhdm
  for x in g:$g a:$da/slang.uhdm b:$db/slang.uhdm; do $UHDM_DUMP ${x#*:} 2>/dev/null | grep -o 'vpiFullName:.*' | LC_ALL=C sort > $T/${x%%:*}; done
  python3 - $T/g $T/a $T/b "$C/$M/$R" <<'PY'
import sys, collections
g, a, b = (collections.Counter(open(f).read().splitlines()) for f in sys.argv[1:4])
lost = (a & g) - b; gained = (b & g) - a
print(f'{sys.argv[4]} names: lost={sum(lost.values())} gained={sum(gained.values())}' + (' | lost e.g. ' + ' ; '.join(list(lost)[:3]) if lost else ''))
PY
done
