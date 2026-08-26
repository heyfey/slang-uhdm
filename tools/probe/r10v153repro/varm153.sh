#!/usr/bin/env bash
# r10v153 verifier — build ONE arm with Surelog (golden) and both frozen
# binaries in BOTH views, score with ct153bind + score153.py, and report the
# official uhdm-cmp line/head counts.  LHS IS ALWAYS GOLDEN.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
PRIS=${PRIS:?set PRIS}
PATCHED=${PATCHED:?set PATCHED}
BIND=${BIND:-./ct153bind}
SCORE=${SCORE:-../r10uvm153repro/score153.py}
F=$(readlink -f "$1"); B=$(basename "$F"); D=${OUT:-/tmp/v153_arms}/wd_${B%.sv}
rm -rf "$D"; mkdir -p "$D"; cp "$F" "$D/"
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
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] || { echo "MISSING $1 or $2"; continue; }
  "$CMP" "$D/$1.uhdm" "$D/$2.uhdm" > "$D/$2.cmp" 2>&1
  echo "cmp $1-vs-$2 rc=$? lines=$(wc -l < "$D/$2.cmp") heads=$(grep -c '^LHS:' "$D/$2.cmp"; true)"
done
for v in "def g o q" "elab ge oe qe"; do
  set -- $v
  [ -f "$D/$2.uhdm" ] || continue
  "$BIND" "$D/$2.uhdm" "$D/$3.uhdm" --all > "$D/pris.$1.bind" 2>&1
  "$BIND" "$D/$2.uhdm" "$D/$4.uhdm" --all > "$D/pat.$1.bind"  2>&1
  echo "=========== ${B%.sv} / $1"
  python3 "$SCORE" "$D/pris.$1.bind" "$D/pat.$1.bind"
done
echo "WD=$D"
