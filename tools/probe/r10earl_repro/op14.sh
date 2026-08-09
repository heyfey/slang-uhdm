#!/bin/bash
# op14.sh <PkgName> [top|all] [paramIndex]  -- r10earl5op on the Earlgrey pair.
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl14_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl5op "$G" "$O" "$1" "$2" "$3"
