#!/bin/bash
# obdist.sh <golden.uhdm> <ours.uhdm> : order-blind uhdm-dump distance (lines of ours not in golden, multiset, the
# case path normalised away).
g=$($UHDM_DUMP $1 2>/dev/null | sed 's|/[^ ,]*/||g' | sort); o=$($UHDM_DUMP $2 2>/dev/null | sed 's|/[^ ,]*/||g' | sort)
comm -13 <(echo "$g") <(echo "$o") | wc -l
