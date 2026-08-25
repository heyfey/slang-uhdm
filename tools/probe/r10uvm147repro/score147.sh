#!/usr/bin/env bash
# r10uvm147 — score ONE arm directory: ct147cen + join147 for golden-vs-pristine
# and golden-vs-patched, in BOTH views.  MEASUREMENT-ONLY; LHS is always golden.
#   usage: [CEN=..] score147.sh <armdir>
set -u
D=$(readlink -f "${1:?armdir}")
CEN=${CEN:-/tmp/r10uvm147_ct147cen}
J=$(dirname "$(readlink -f "$0")")/join147.py
for x in g o q ge oe qe; do
  [ -f "$D/$x.uhdm" ] && "$CEN" "$D/$x.uhdm" --sel > "$D/$x.cen" 2>/dev/null
done
[ -f "$D/o.cen" ] && { printf "  DEF  pris: "; python3 "$J" "$D/g.cen" "$D/o.cen" | tail -1; }
[ -f "$D/q.cen" ] && { printf "  DEF  patc: "; python3 "$J" "$D/g.cen" "$D/q.cen" | tail -1; }
[ -f "$D/oe.cen" ] && { printf "  ELAB pris: "; python3 "$J" "$D/ge.cen" "$D/oe.cen" | tail -1; }
[ -f "$D/qe.cen" ] && { printf "  ELAB patc: "; python3 "$J" "$D/ge.cen" "$D/qe.cen" | tail -1; }
