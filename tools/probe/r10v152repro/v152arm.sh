#!/usr/bin/env bash
# r10v152 (verifier) — build ONE arm with Surelog (golden) and the two frozen
# binaries in BOTH views, score each with the OFFICIAL uhdm-cmp, and dump all
# six databases.  LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY.
#   usage: PRIS=.. PATCHED=.. v152arm.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
PRIS=${PRIS:?set PRIS}; PATCHED=${PATCHED:?set PATCHED}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
rm -rf "$D/slpp_all" "$D/slpp_unit"
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache -sv "$B" >sle.log 2>&1 </dev/null ); echo "SLe   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for pair in "g o" "g q" "ge oe" "ge qe"; do
  set -- $pair
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] || { echo "$1-vs-$2 MISSING"; continue; }
  "$CMP" "$D/$1.uhdm" "$D/$2.uhdm" > "$D/$2.cmp" 2>&1
  echo "$1-vs-$2 cmp rc=$? lines=$(wc -l < "$D/$2.cmp") heads=$(grep -c '^LHS:' "$D/$2.cmp"; true)"
done
for u in g ge o oe q qe; do
  [ -f "$D/$u.uhdm" ] && "$DUMP" "$D/$u.uhdm" > "$D/$u.dump" 2>/dev/null
done
echo "WD=$D"
