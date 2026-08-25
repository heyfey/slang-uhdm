#!/usr/bin/env bash
# r10uvm136 — build ONE arm with Surelog (golden) and with the frozen binaries,
# in BOTH views, census each with cen136 and score with the OFFICIAL uhdm-cmp.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the judge is uhdm-cmp.
#   usage: PRIS=.. [PATCHED=..] [CEN136=..] arm136.sh <file.sv> <outdir>
# Every child gets </dev/null; every rc is printed (rc=139 is a SEGFAULT and
# verify_golden would have called it a SLANG_REJECT).
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
CEN=${CEN136:-}
PRIS=${PRIS:?set PRIS}; PATCHED=${PATCHED:-}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
# sibling headers of the SAME arm (`include`d): copied by the arm's own
# basename prefix, never by a bare glob over the probe directory.
for h in "$(dirname "$F")/$(basename "${F%.*}")"_inc*.svh; do [ -f "$h" ] && cp "$h" "$D/"; done
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
if [ -n "$PATCHED" ]; then
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
fi
if [ -n "$CEN" ]; then
for t in g o oe q qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.cen"
  echo "$t cencells=$(wc -l < "$D/$t.cen")"
done
fi
for t in o q; do
  [ -f "$D/$t.uhdm" ] && [ -f "$D/g.uhdm" ] || continue
  "$CMP" "$D/g.uhdm" "$D/$t.uhdm" > "$D/$t.cmp" 2>&1
  echo "$t cmp rc=$? lines=$(wc -l < "$D/$t.cmp") heads=$(grep -c '^LHS:' "$D/$t.cmp"; true)"
done
echo "WD=$D"
