#!/bin/bash
# usage: WORKROOT=<matrix workroot> svtests_diff.sh <relative test path of a kept non-identical row> [lines]
# Prints the first changed lines of the normalized uhdm-dump diff, golden minus ours.
REPO=$(cd "$(dirname "$0")/../.." && pwd)
D=${UHDM_DUMP:-$REPO/third_party/Surelog/build/third_party/UHDM/bin/uhdm-dump}
rel=$1; n=${2:-40}; w=$WORKROOT/${rel%.sv}
norm() { sed -E "s/\\bid:[0-9]+/id:_/g; s#$WORKROOT/[^ ,]*/##g" ; }
$D $w/slpp_all/surelog.uhdm 2>/dev/null | norm > $w/golden.dump
$D $w/slang.uhdm 2>/dev/null | norm > $w/ours.dump
echo "== $rel golden $(wc -l < $w/golden.dump) ours $(wc -l < $w/ours.dump) lines"
diff -u $w/golden.dump $w/ours.dump | grep -vE '^(---|\+\+\+)' | grep -E '^[-+@]' | head -n $n
