#!/bin/bash
# r11u193: order-blind strict-record distance of one corpus row-mode to its golden, per sweep workdir: the multiset of
# uhdm-strictcmp's per-object records (depth dropped) ours-not-in-golden (dist) and golden-not-in-ours (miss).
# usage: rowdist.sh <corpus> <mode> <row> <workdir>...   (refuses fenced rows)
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 3
C=$1; M=$2; R=$3; shift 3; r193_fenced "$R" && { echo "rowdist.sh: fenced row refused"; exit 3; }
for W in "$@"; do
  d=$(ls -d $W/$C/$M/$R-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
  $SCMP --max 0 --dump-a /tmp/r11u193_rd_a --dump-b /tmp/r11u193_rd_b $gu $d/slang.uhdm > /dev/null 2>&1
  python3 - /tmp/r11u193_rd_a /tmp/r11u193_rd_b "$W $C/$M/$R" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print('%s dist=%d miss=%d' % (sys.argv[3], sum((b - a).values()), sum((a - b).values())))
PY
done
