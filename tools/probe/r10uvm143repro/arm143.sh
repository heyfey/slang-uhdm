#!/usr/bin/env bash
# r10uvm143 — build ONE arm with Surelog (golden) and with the frozen binaries,
# in BOTH views, census each with cen143 and score with the OFFICIAL uhdm-cmp.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the judge is uhdm-cmp.
#   usage: PRIS=.. [PATCHED=..] [CEN143=..] arm140.sh <file.sv> <outdir>
# Every child gets </dev/null; every rc is printed (rc=139 is a SEGFAULT and
# verify_golden would have called it a SLANG_REJECT).
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
CEN=${CEN143:-}
PRIS=${PRIS:?set PRIS}; PATCHED=${PATCHED:-}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
# sibling headers of the SAME arm (`include`d): copied by the arm's own
# basename prefix, never by a bare glob over the probe directory.
for h in "$(dirname "$F")/$(basename "${F%.*}")"_inc*.svh; do [ -f "$h" ] && cp "$h" "$D/"; done
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache $LANG_FLAG "$B" >sle.log 2>&1 </dev/null ); echo "SLE   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
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
for pair in "g o" "g q" "ge oe" "ge qe"; do
  set -- $pair; G=$1; T=$2
  [ -f "$D/$T.uhdm" ] && [ -f "$D/$G.uhdm" ] || continue
  "$CMP" "$D/$G.uhdm" "$D/$T.uhdm" > "$D/$T.cmp" 2>&1
  echo "$T cmp rc=$? lines=$(wc -l < "$D/$T.cmp") heads=$(grep -c '^LHS:' "$D/$T.cmp"; true)"
done
echo "WD=$D"
