#!/usr/bin/env bash
# r10v126 (VERIFIER) — one arm: Surelog golden in BOTH views + both frozen
# binaries in both views, census each with cenv126 (element typespec kind, name,
# span, RANGE COUNT, **VpiSigned** and vpiInstance).  LHS IS ALWAYS GOLDEN.
# MEASUREMENT ONLY — the official uhdm-cmp is the judge.
#   usage: PRIS=.. PATCHED=.. CEN=.. armv126.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
CEN=${CEN:-/tmp/v126_cenv}
PRIS=${PRIS:?set PRIS}; PATCHED=${PATCHED:?set PATCHED}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >slp.log 2>&1 </dev/null ); echo "SLdef rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
rm -rf "$D/slpp_all" "$D/slpp_unit"
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache $LANG_FLAG "$B" >sle.log 2>&1 </dev/null ); echo "SLelab rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g ge o oe q qe; do
  [ -f "$D/$t.uhdm" ] || { echo "$t MISSING"; continue; }
  "$CEN" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.cen"
  echo "$t cencells=$(wc -l < "$D/$t.cen")"
done
for p in "g o" "g q" "ge oe" "ge qe"; do
  set -- $p
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] || continue
  "$CMP" "$D/$1.uhdm" "$D/$2.uhdm" > "$D/$1_$2.cmp" 2>&1
  echo "cmp $1 vs $2 rc=$? lines=$(wc -l < "$D/$1_$2.cmp") heads=$(grep -c '^LHS:' "$D/$1_$2.cmp"; true)"
done
echo "WD=$D"
