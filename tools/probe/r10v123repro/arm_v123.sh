#!/usr/bin/env bash
# r10v123 (VERIFIER) — one arm: Surelog golden in BOTH views + both frozen
# binaries in BOTH views, censused with cast123 and judged by the OFFICIAL
# uhdm-cmp in BOTH views.  LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY.
#   usage: PRIS=.. PATCHED=.. CAST123=.. arm_v123.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
CEN=${CAST123:?set CAST123}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
# the CORPUS flags: verify_golden.py passes --single-unit --nobuiltin; without
# --nobuiltin every arm cmp is swamped by the builtin package (2478 vs 122
# lines on v123_m2_plain_min) and the "non-increasing" reading is worthless.
SUA=${SUA:---single-unit --nobuiltin}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
# DEF view golden
( cd "$D" && rm -rf slpp_all slpp_unit && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SL   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
# ELAB view golden
( cd "$D" && rm -rf slpp_all slpp_unit && "$SL" -parse -elabuhdm -nobuiltin -nocache $LANG_FLAG "$B" >sle.log 2>&1 </dev/null ); echo "SLE  rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B" $SUA           -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" $SUA --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B" $SUA           -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" $SUA --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in g ge o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.cast"
  echo "$t castcells=$(wc -l < "$D/$t.cast")"
done
# the OFFICIAL judge, BOTH views
for pair in "g o def" "g q def" "ge oe elab" "ge qe elab"; do
  set -- $pair
  [ -f "$D/$1.uhdm" ] && [ -f "$D/$2.uhdm" ] || continue
  "$CMP" "$D/$1.uhdm" "$D/$2.uhdm" > "$D/$2.cmp" 2>&1
  echo "CMP $3 $1-vs-$2 rc=$? lines=$(wc -l < "$D/$2.cmp") heads=$(grep -c '^LHS:' "$D/$2.cmp"; true)"
done
echo "WD=$D"
