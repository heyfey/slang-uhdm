#!/bin/bash
# r11u200: order-blind distance of named row-modes (corpus/mode/test) of sweep workdirs to their goldens: the
# uhdm-strictcmp record multisets (depth dropped), ours-not-in-golden count.  Fail-closed on the fence.
# usage: obdist.sh "<corpus/mode/test> ..." <sweep workdir>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
ROWS=$1; shift; T=/tmp/r11u200_obdist; mkdir -p $T
for W in "$@"; do for r in $ROWS; do
  IFS=/ read c m t <<< "$r"; for f in $FENCED; do [ "$f" = "$t" ] && { echo "fenced refused"; exit 3; }; done
  d=$(ls -d $W/$c/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || continue
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $d/cmds.txt | head -1)
  $SCMP --max 0 --dump-a $T/a --dump-b $T/b $g/golden.uhdm $d/slang.uhdm > /dev/null 2>&1
  python3 - $T/a $T/b "$W" "$r" <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print('%s %s dist=%d' % (sys.argv[3], sys.argv[4], sum((b - a).values())))
PY
done; done
