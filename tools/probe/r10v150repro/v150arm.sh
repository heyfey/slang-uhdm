#!/usr/bin/env bash
# r10v150 — build ONE arm with Surelog (GOLDEN, always LHS) and both frozen
# binaries, in BOTH views, produce uhdm-dumps of all six databases and score
# with the OFFICIAL uhdm-cmp.  Every child gets </dev/null; every rc printed.
#   usage: PRIS=.. PATCHED=.. v150arm.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
PRIS=${PRIS:?set PRIS}; PATCHED=${PATCHED:?set PATCHED}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log  2>&1 </dev/null ); echo "SL    rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
rm -rf "$D/slpp_all" "$D/slpp_unit"
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache -sv "$B" >sle.log 2>&1 </dev/null ); echo "SLe   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for n in g ge o oe q qe; do [ -f "$D/$n.uhdm" ] && "$DUMP" "$D/$n.uhdm" > "$D/$n.dump" 2>/dev/null; done
for pair in "g o" "g q" "ge oe" "ge qe"; do
  set -- $pair
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] || { echo "$pair SKIP-NOFILE"; continue; }
  "$CMP" "$D/$1.uhdm" "$D/$2.uhdm" > "$D/$2.cmp" 2>&1
  echo "$1-vs-$2 cmp rc=$? lines=$(wc -l < "$D/$2.cmp") heads=$(grep -c '^LHS:' "$D/$2.cmp"; true)"
done
echo "WD=$D"
