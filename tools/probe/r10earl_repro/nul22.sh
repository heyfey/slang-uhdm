#!/bin/bash
# nul19.sh <vec> <Listing> <selector> [-deep] -- nullness/size walk (r10earl17d)
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${EARL_OURS:-/tmp/r10earl22_e0w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10e22_17d "$G" "$O" "$@"
