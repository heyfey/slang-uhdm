#!/bin/bash
# obrow.sh <sweep workdir> <corpus> <mode> <row>... : ORDER-BLIND distance of a sweep row's database to its golden:
# uhdm-strictcmp's per-object records (--max 0 --dump-a/-b) as multisets with the depth column dropped; prints
# ours-not-in-golden + golden-not-in-ours.  Fail-closed on $FENCED; a fenced row is refused.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "obrow.sh: export FENCED" >&2; exit 2; }
W=$1 C=$2 M=$3; shift 3; T=/tmp/r11u176_scratch/obrow.$$; mkdir -p $T
for R in "$@"; do
  for f in $FENCED; do [ "$f" = "$R" ] && { echo "$R fenced refused"; continue 2; }; done
  d=$(ls -d $W/$C/$M/$R-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || { echo "$R nodb"; continue; }
  g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
  $STRICT_CMP --max 0 --dump-a $T/a --dump-b $T/b $gu $d/slang.uhdm > /dev/null 2>&1
  python3 - "$T/a" "$T/b" "$R" "$M" "$W" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print(f"{sys.argv[5]} {sys.argv[3]} {sys.argv[4]} ours-not-golden={sum((b-a).values())} golden-not-ours={sum((a-b).values())}")
PY
done
rm -rf $T
