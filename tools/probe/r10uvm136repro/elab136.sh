#!/usr/bin/env bash
# r10uvm136 — the DEF/ELAB half of the grid.  Surelog is run a SECOND time with
# `-elabuhdm` so the ELAB view has its OWN golden, and the same cen136 census is
# scored in that view.  (verify_golden's corpus rows are DEF-view; this arm is
# the only place the elaborated view gets a golden of its own.)
#   usage: PRIS=.. PATCHED=.. CEN136=.. elab136.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=${CEN136:?}; PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
for h in "$(dirname "$F")/$(basename "${F%.*}")"_inc*.svh; do [ -f "$h" ] && cp "$h" "$D/"; done
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache -sv "$B" >sle.log 2>&1 </dev/null ); echo "SLe   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in ge oe qe; do "$CEN" "$D/$t.uhdm" 2>/dev/null | sort > "$D/$t.cen"; echo "$t cencells=$(wc -l < "$D/$t.cen")"; done
echo "WD=$D"
