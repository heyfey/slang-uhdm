#!/bin/bash
# bis17.sh <vec> <Listing> <selector> [maxdepth] -- generic bisect (r10earl17c)
# of one listing child: prints the exact FIELD CHAIN uhdm-cmp walks to the
# difference, with no hand-written descent.
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${EARL_OURS:-/tmp/r10earl17_e0w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl17c "$G" "$O" "$@"
