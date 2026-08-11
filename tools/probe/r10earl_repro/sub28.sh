#!/bin/bash
# sub25.sh <vec> <Name> [-v] -- COMPLETE sub-census (r10earl17a) of one listing
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${EARL_OURS:-/tmp/r10earl28_e0w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
${EARL_PROBE:-/tmp/r10e28_17a} "$G" "$O" "$@"
