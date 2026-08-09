#!/bin/bash
# pins15.sh <vec> <Name> -- r10earl14e (parameter typespec Instance()) on one
# Earlgrey listing, both sides.
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl16_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl14e "$G" "$O" "$@"
