#!/bin/bash
# q14.sh <probe> [args...]  -- run a two-database probe on the Earlgrey pair.
P=$1; shift
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl14_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
"/tmp/$P" "$G" "$O" "$@" | sed 's#/home/heyfey/git-repos/Surelog/third_party/tests/Earlgrey_0_1/src/##g'
