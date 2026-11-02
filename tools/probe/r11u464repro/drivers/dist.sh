#!/bin/bash
# dist.sh <golden.uhdm> <ours.uhdm>: path-normalized uhdm-dump diff line count (distance to golden)
source $(dirname "$0")/env.sh || exit 1
G=$1; O=$2
n() { $UHDM_DUMP "$1" 2>&1 | tail -n +2 | sed -E 's/, id:[0-9]+//; s#file:[^,]*/##'; }
diff <(n "$G") <(n "$O") | grep -c '^[<>]'
