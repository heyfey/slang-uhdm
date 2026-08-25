#!/usr/bin/env bash
# r10uvm138 — the ELAB half of the grid.  Surelog is run a SECOND time with
# `-elabuhdm` so the ELABORATED view has a golden of its OWN, and the same
# cen138 census is scored there.  (verify_golden's corpus rows are the folded
# view; this is the only place the elaborated view gets its own golden.)
#   usage: PRIS=.. PATCHED=.. elab138.sh <file.sv> <outdir>
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -elabuhdm -nobuiltin -nocache -sv "$B" >sle.log 2>&1 </dev/null ); echo "SLe   rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/ge.uhdm"; done
( cd "$D" && "$PRIS"    "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
for t in ge oe qe; do
  [ -f "$D/$t.uhdm" ] || continue
  "$DUMP" "$D/$t.uhdm" 2>/dev/null | python3 "$HERE/cen138.py" - > "$D/$t.cen"
  echo "$t cencells=$(wc -l < "$D/$t.cen")"
done
echo "WD=$D"
