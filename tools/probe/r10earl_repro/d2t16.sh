#!/bin/bash
# d2t15.sh <pkg> -- inside the GOLDEN alone, and then inside OURS alone: does
# the DEF package copy differ from the TOP package copy?  If golden's own two
# copies differ the same way ours do, § pkgTypespecInstanceIsTop is purely a
# POINTER question (which copy a module typespec names), not a content one.
G=/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm
O=${EARL_OURS:-/tmp/r10earl16_aww/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
P=$1
echo "=== GOLDEN def-vs-top $P"
/tmp/r10earl15b "$G" "$G" def2top "$P" 2>&1 | head -20
echo "=== OURS   def-vs-top $P"
/tmp/r10earl15b "$O" "$O" def2top "$P" 2>&1 | head -20
