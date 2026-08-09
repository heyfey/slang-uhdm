#!/bin/bash
# usage: cen5.sh <probe> <outfile> [extra args]   -> Earlgrey_0_1 golden vs ours
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl15_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
P=$1; F=$2; shift 2
"/tmp/$P" "$G" "$O" "$@" > "$F" 2>&1
echo "rc=$? -> $F  ($(wc -l < "$F") lines)"
