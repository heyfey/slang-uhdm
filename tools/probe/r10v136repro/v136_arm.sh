#!/usr/bin/env bash
# v136 verifier's OWN arm driver.  LHS is ALWAYS golden.  Every child </dev/null,
# every rc printed.  Scratch keyed on the RELATIVE path of the arm.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
SRCROOT=$(readlink -f "$1"); REL="$2"; OUT=$(readlink -f "$3")
F="$SRCROOT/$REL"; B=$(basename "$F")
D="$OUT/$(echo "$REL" | tr '/' '_')"; mkdir -p "$D"
cp "$F" "$D/"
for h in "$(dirname "$F")/$(basename "${F%.*}")"_inc*.svh; do [ -f "$h" ] && cp "$h" "$D/"; done
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); echo "  SL   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache -sv "$B" >sle.log 2>&1 </dev/null ); echo "  SLe  rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B" --nobuiltin           -o o.uhdm  >o.log  2>&1 </dev/null ); echo "  pris rc=$?"
( cd "$D" && "$PRIS"    "$B" --nobuiltin --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "  prsE rc=$?"
( cd "$D" && "$PATCHED" "$B" --nobuiltin           -o q.uhdm  >q.log  2>&1 </dev/null ); echo "  patc rc=$?"
( cd "$D" && "$PATCHED" "$B" --nobuiltin --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "  patE rc=$?"
for pair in "g o" "g q" "ge oe" "ge qe"; do
  set -- $pair
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] || { echo "  cmp $1/$2 SKIP-NOFILE"; continue; }
  "$CMP" "$D/$1.uhdm" "$D/$2.uhdm" > "$D/cmp_$1_$2.txt" 2>&1
  echo "  cmp $1/$2 rc=$? lines=$(wc -l < "$D/cmp_$1_$2.txt") heads=$(grep -c '^LHS:' "$D/cmp_$1_$2.txt"; true)"
done
echo "  WD=$D"
