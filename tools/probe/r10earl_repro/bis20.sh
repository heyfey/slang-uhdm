#!/bin/bash
# bis19.sh <vec> <Listing> <selector> [maxdepth] -- generic bisect (r10earl17c)
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${EARL_OURS:-/tmp/r10earl20_e0w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10e20_17c "$G" "$O" "$@"
