#!/bin/bash
# run1.sh <tag> <binary> [ENV=VAL ...] < list of case dirs: runs case.sh on each in both views, 3 in parallel,
# one line per case-view (case.sh's line). Fence fail-closed through env.sh / case.sh.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
t=$1; b=$2; shift 2
export HERE t b; export ENVX="$*"
while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'EL=$1 bash $HERE/case.sh $0 $t $b $ENVX' | sort
