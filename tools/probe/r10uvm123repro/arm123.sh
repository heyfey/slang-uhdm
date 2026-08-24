#!/usr/bin/env bash
# r10uvm123 — build ONE arm with Surelog (golden) and with the frozen binaries,
# in BOTH views, and census each with cast123 + score with the OFFICIAL uhdm-cmp.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY.
#   usage: PRIS=.. [PATCHED=..] CAST123=.. arm123.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
CEN=${CAST123:?set CAST123}
PRIS=${PRIS:?}; PATCHED=${PATCHED:-}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
if [ -n "$PATCHED" ]; then
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
fi
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.cast"
  echo "$t castcells=$(wc -l < "$D/$t.cast")"
done
# the OFFICIAL judge: golden vs each of ours (cmp lines; 0 == CMP_EQUAL)
for t in o q; do
  [ -f "$D/$t.uhdm" ] && [ -f "$D/g.uhdm" ] || continue
  "$CMP" "$D/g.uhdm" "$D/$t.uhdm" > "$D/$t.cmp" 2>&1
  echo "$t cmp rc=$? lines=$(wc -l < "$D/$t.cmp") heads=$(grep -c '^LHS:' "$D/$t.cmp"; true)"
done
echo "WD=$D"
