#!/bin/bash
# v11u207 (from r11u207repro): order-blind distance of one corpus row-mode to its golden: obrow.sh <sweep wd> <corpus> <mode> <test>
# (uhdm-strictcmp's per-object records as multisets, depth dropped: ours-not-in-golden + golden-not-in-ours).
# Refuses the four fenced tests (env.sh, fail closed).
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
W=$1 C=$2 M=$3 T=$4
for f in $FENCED; do [ "$T" = "$f" ] && { echo "obrow: fenced test refused" >&2; exit 3; }; done
d=$(ls -d $W/$C/$M/$T-* | head -1); g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
o=/tmp/v11u207_obrow/$(basename $W)/$C/$M/$T; mkdir -p $o
$SCMP --max 0 --dump-a $o/a --dump-b $o/b $gu $d/slang.uhdm > /dev/null 2>&1
python3 - $o/a $o/b "$W $C/$M/$T" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print(sys.argv[3], 'dist=%d rev=%d total=%d' % (sum((b-a).values()), sum((a-b).values()), sum((b-a).values()) + sum((a-b).values())))
PY
