#!/bin/bash
# cen25.sh <tag> -- r10earl4h head census into /tmp/r10earl25_cen_<tag>.txt
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${EARL_OURS:-/tmp/r10earl25_e0w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
T=${1:-base}
/tmp/r10e24_4h "$G" "$O" > "/tmp/r10earl25_cen_$T.txt" 2>&1
echo "rc=$? -> /tmp/r10earl25_cen_$T.txt"
grep -E '^== |head\(s\)' "/tmp/r10earl25_cen_$T.txt"
