#!/bin/bash
# pts15.sh <vec> <Listing> <Param> -- r10earl15c typespec tree, both sides.
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl15_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl15c "$G" "$O" "$@"
