#!/usr/bin/env bash
# r10uvm163 — RE-MEASURE a boundary mover AGAINST GOLDEN.  A moved arm is not a
# regression and not a win until Surelog has been run on it and every cell
# scored, so this rebuilds golden in BOTH views and hands the six databases to
# cells163.py.  MEASUREMENT ONLY.  LHS is ALWAYS golden(Surelog).
#   usage: PRIS=.. PATCHED=.. CT163CEN=.. remeasure163.sh <file.sv> <outdir>
# GUARDS: every rc is printed (rc=139 is a SEGFAULT, which verify_golden would
# have mislabelled SLANG_REJECT); children get </dev/null; a view whose golden
# could not be built is reported and the scorer says MISSING rather than clean.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
for h in "$(dirname "$F")"/*.svh "$(dirname "$F")"/*.vh; do [ -f "$h" ] && cp "$h" "$D/"; done
LANG_FLAG=-sv; case "$B" in *.v) LANG_FLAG=;; esac
( cd "$D" && "$SL" -parse -nobuiltin -nocache $LANG_FLAG "$B" >sl.log 2>&1 </dev/null ); echo "SL    rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
rm -rf "$D/slpp_all" "$D/slpp_unit"
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache $LANG_FLAG "$B" >sle.log 2>&1 </dev/null ); echo "SLe   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
bash "$(dirname "$0")/armcen163.sh" "$D"
