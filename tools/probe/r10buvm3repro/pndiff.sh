#!/usr/bin/env bash
# r10buvm3 — PRISTINE-vs-PATCHED dump delta for one arm, with the WORKDIR PATH
# NORMALIZED OUT.  uhdm-dump embeds the absolute path of every source file, so
# two runs in two directories differ on hundreds of lines that have nothing to
# do with the patch; a `diff` that is not normalized reads as a huge over-fire.
#   usage: pndiff.sh <arm.sv> <pristine-bin> <patched-bin>
# Prints: the GOLDEN-vs-OURS content count for each binary, then the P-vs-N
# delta (what the patch actually moved), then the cells that MATCHED golden
# only after the patch.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=${1:?arm}; P=${2:?pristine}; N=${3:?patched}
B=$(basename "$SRC"); B=${B%.*}
DP=/tmp/r10buvm3_pn_${B}_P; DN=/tmp/r10buvm3_pn_${B}_N
SLANG_UHDM=$P "$HERE/ct3arm.sh" "$SRC" "$DP" > "$DP.log" 2>&1
SLANG_UHDM=$N "$HERE/ct3arm.sh" "$SRC" "$DN" > "$DN.log" 2>&1
for d in "$DP" "$DN"; do
  [ -s "$d/o.dump" ] || { echo "FATAL: no o.dump in $d"; cat "$d.log"; exit 3; }
done
norm() { sed "s#$2#@WD@#g" "$1"; }
norm "$DP/o.dump" "$DP" > /tmp/r10buvm3_pn_${B}_P.norm
norm "$DN/o.dump" "$DN" > /tmp/r10buvm3_pn_${B}_N.norm
norm "$DP/g.dump" "$DP" > /tmp/r10buvm3_pn_${B}_G.norm
norm "$DN/g.dump" "$DN" > /tmp/r10buvm3_pn_${B}_GN.norm
cmp -s /tmp/r10buvm3_pn_${B}_G.norm /tmp/r10buvm3_pn_${B}_GN.norm \
  || { echo "FATAL: the two GOLDEN dumps differ after normalization"; exit 4; }
gp=$(diff -u /tmp/r10buvm3_pn_${B}_G.norm /tmp/r10buvm3_pn_${B}_P.norm | grep -cE '^[-+]' )
gn=$(diff -u /tmp/r10buvm3_pn_${B}_G.norm /tmp/r10buvm3_pn_${B}_N.norm | grep -cE '^[-+]' )
echo "$B: golden-vs-PRISTINE=$((gp-2))  golden-vs-PATCHED=$((gn-2))  (lower is better)"
echo "-- P vs N delta (the patch's OWN movement) --"
diff -u /tmp/r10buvm3_pn_${B}_P.norm /tmp/r10buvm3_pn_${B}_N.norm \
  | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) '
