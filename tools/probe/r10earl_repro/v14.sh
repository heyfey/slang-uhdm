#!/bin/bash
# v14.sh <all|top|allpkg|toppkg> <Name>  -- r10earl14a on the Earlgrey pair.
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl14_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl14a "$G" "$O" "$1" "$2" "$3" | sed 's#/home/heyfey/git-repos/Surelog/third_party/tests/Earlgrey_0_1/src/##g'
