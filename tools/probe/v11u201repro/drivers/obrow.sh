#!/bin/bash
# obrow.sh <sweep wd> <corpus> <mode> <test> : order-blind record distance (strictcmp records, depth dropped); fail closed on the fence
. "$(cd "$(dirname "$0")" && pwd)/env.sh" || exit 3
W=$1 C=$2 M=$3 T=$4
for f in $FENCED; do [ "$T" = "$f" ] && { echo "obrow: fenced test refused" >&2; exit 3; }; done
d=$(ls -d $W/$C/$M/$T-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
o=/tmp/v11u201_obrow/$(basename $W)/$C/$M/$T; mkdir -p $o
$SCMP --max 0 --dump-a $o/a --dump-b $o/b $gu $d/slang.uhdm > /dev/null 2>&1
python3 - $o/a $o/b "$(basename $W) $C/$M/$T" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print(sys.argv[3], 'dist=%d rev=%d total=%d' % (sum((b-a).values()), sum((a-b).values()), sum((b-a).values()) + sum((a-b).values())))
PY
