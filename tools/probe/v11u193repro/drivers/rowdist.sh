#!/bin/bash
# rowdist.sh <corpus> <mode> <row> <workdir>... : order-blind strict-record distance (dist ours-not-in-golden, miss golden-not-in-ours)
. "$(dirname "$0")/env.sh" || exit 3
C=$1; M=$2; R=$3; shift 3; v193_fenced "$R" && { echo "fenced row refused"; exit 3; }
for W in "$@"; do
  d=$(ls -d $W/$C/$M/$R-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
  t=/tmp/v11u193_rd_$$; $SCMP --max 0 --dump-a ${t}_a --dump-b ${t}_b $gu $d/slang.uhdm > /dev/null 2>&1
  python3 - ${t}_a ${t}_b "$W $C/$M/$R" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print('%s dist=%d miss=%d' % (sys.argv[3], sum((b - a).values()), sum((a - b).values())))
PY
  rm -f ${t}_a ${t}_b
done
