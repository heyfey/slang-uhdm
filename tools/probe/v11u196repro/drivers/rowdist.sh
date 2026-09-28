#!/bin/bash
# rowdist.sh <sweep workdir> <test> <mode>: order-blind strict-record distance (ours-not-in-golden), fence fail-closed
. "$(dirname "$0")/env.sh"; W=$1; t=$2; m=$3
for f in $FENCED; do [ "$f" = "$t" ] && { echo refused; exit 3; }; done
T=/tmp/v11u196_rowdist_$$; mkdir -p $T
d=$(ls -d $W/surelog/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || { echo "$W $t/$m nodb"; exit 0; }
g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
$STRICT_CMP --max 0 --dump-a $T/a --dump-b $T/b $gu $d/slang.uhdm > /dev/null 2>&1
python3 - $T/a $T/b "$W $t/$m" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print(sys.argv[3], 'dist=%d' % sum((b - a).values()), 'miss=%d' % sum((a - b).values()))
PY
rm -rf $T
