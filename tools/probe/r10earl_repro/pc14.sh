#!/bin/bash
# pc14.sh <PkgName> [top]  -- r10earl4pc on the Earlgrey pair.
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl14_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl4pc "$G" "$O" "$1" "$2"
