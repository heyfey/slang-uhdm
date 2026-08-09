#!/bin/bash
# dd17.sh <vec> <Listing> <selector> -- dump ONE child subtree from both
# databases with r10earl17b (UHDM's own visit_object) and print the normalised
# diff.  Normalisation: absolute source paths -> basename, uid/line numbers
# kept (they are the localisation).  This is the generic replacement for the
# hand-written descents in r10earl15c / r10earl16a.
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${EARL_OURS:-/tmp/r10earl17_e0w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
/tmp/r10earl17b "$G" "$O" "$1" "$2" "$3" /tmp/r10earl17b_g.txt /tmp/r10earl17b_o.txt || exit $?
sed -E 's#/[^ ,|]*/##g' /tmp/r10earl17b_g.txt > /tmp/r10earl17b_gn.txt
sed -E 's#/[^ ,|]*/##g' /tmp/r10earl17b_o.txt > /tmp/r10earl17b_on.txt
diff /tmp/r10earl17b_gn.txt /tmp/r10earl17b_on.txt
echo "(diff rc=$?; raw: /tmp/r10earl17b_{g,o}.txt  norm: /tmp/r10earl17b_{g,o}n.txt)"
