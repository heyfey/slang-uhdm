#!/bin/bash
# obcase.sh <binA> <binB> <probe case rel>...: per probe case (tests/probe/<rel>/dut.sv, run on a scratch copy),
# the order-blind record distance to golden (records ours holds that golden does not, multiset, depth dropped;
# plus the reverse) under both binaries, and the strict verdict line. Fail-closed on $FENCED.
set -u; : "${FENCED:?FENCED unset}"
A=$1; Bb=$2; shift 2; D=$(cd "$(dirname "$0")" && pwd)
for rel in "$@"; do
  for f in $FENCED; do echo "$rel" | grep -qw "$f" && { echo "$rel fenced: refused"; continue 2; }; done
  C=/tmp/r11u175_scratch/obc/$(echo $rel | tr '/' '_'); rm -rf $C; mkdir -p $C/case; cp /tmp/wt_r11u175/tests/probe/$rel/dut.sv $C/case/
  for tag in A B; do bin=$A; [ $tag = B ] && bin=$Bb
    OUT=$C/out TAG=$tag bash $D/case.sh $C/case $bin > $C/$tag.line
    o=$(ls -d $C/out/*.$tag | head -1)
    python3 - $o/a.rec $o/b.rec > $C/$tag.dist <<'PY'
import sys, collections
a = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[1]) if '\t' in l)
b = collections.Counter(l.split('\t', 1)[1] for l in open(sys.argv[2]) if '\t' in l)
print(sum((b - a).values()), sum((a - b).values()))
PY
  done
  echo "$rel A(ours-only,golden-only)=$(cat $C/A.dist) B=$(cat $C/B.dist) | A: $(sed 's/.*strict=/strict=/' $C/A.line) | B: $(sed 's/.*strict=/strict=/' $C/B.line)"
done
