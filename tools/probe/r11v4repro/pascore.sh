#!/bin/bash
# v11u4 VERIFIER — COMPARE-VISIBLE anti-regression scorer for one grid arm.
#   usage: pascore.sh <armdir> <pristine-tag> <patched-tag>
# Reads the golden built for the arm and both our databases, and scores the
# param_assign census on COMPARE-VISIBLE fields only (pacen.py).  LOST = a row
# that matched golden BEFORE the patch and does not after.
set -u
A=$(readlink -f "${1:?arm dir}"); PT=${2:-pristine}; QT=${3:-patched}
H=$(dirname "$(readlink -f "$0")")
G="$A/w_$PT/golden.dump"; P="$A/w_$PT/ours.dump"; Q="$A/w_$QT/ours.dump"
for f in "$G" "$P" "$Q"; do [ -f "$f" ] || { echo "MISSING $f"; exit 2; }; done
T=$(mktemp -d /tmp/v11u4_sc.XXXXXX)
python3 "$H/pacen.py" "$G" | sort > "$T/g"
python3 "$H/pacen.py" "$P" | sort > "$T/p"
python3 "$H/pacen.py" "$Q" | sort > "$T/q"
gp=$(comm -12 "$T/g" "$T/p" | grep -c .; true)
gq=$(comm -12 "$T/g" "$T/q" | grep -c .; true)
comm -23 <(comm -12 "$T/g" "$T/p") <(comm -12 "$T/g" "$T/q") > "$T/lost"
comm -13 <(comm -12 "$T/g" "$T/p") <(comm -12 "$T/g" "$T/q") > "$T/won"
lost=$(grep -c . "$T/lost"; true); won=$(grep -c . "$T/won"; true)
printf '%-10s golden_rows=%-4s agree_pris=%-4s agree_pat=%-4s WON=%-3s LOST=%s\n' \
   "$(basename "$A")" "$(wc -l < "$T/g")" "$gp" "$gq" "$won" "$lost"
[ "$lost" != 0 ] && sed 's/^/    LOST /' "$T/lost"
[ "${SHOWWON:-0}" = 1 ] && sed 's/^/    WON  /' "$T/won"
rm -rf "$T"
exit 0
