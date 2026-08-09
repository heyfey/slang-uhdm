#!/bin/bash
# p14.sh <probe> <side:g|o> [probe args...]  -- run a probe on the Earlgrey pair.
P=$1; S=$2; shift 2
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl14_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
if [ "$S" = g ]; then D=$G; else D=$O; fi
"/tmp/$P" "$D" "$@"
