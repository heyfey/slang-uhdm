#!/bin/bash
# r10uvm56repro/cells.sh — the ARM CELL TABLE.  One CELL per (owning routine,
# return-name reference, line:col); both sides printed, at the reference's OWN
# CHILD DEPTH (the census reads Actual_group off the reference object itself,
# never off a nested one), and a DIFFERING count at the end.
#
#   usage: cells.sh <arm-outdir>          # after arm.sh has run
#
# GUARD: a missing census input is a hard failure, never an empty table that
# reads as "0 differing".
set -u
OUT=${1:?arm outdir}
CEN=${R10UVM56_28G:-/tmp/r10uvm56_28g}
[ -x "$CEN" ] || { echo "FATAL: no census probe at $CEN"; exit 3; }
G=$OUT/slpp_all/surelog.uhdm
O=$OUT/ours.uhdm
for f in "$G" "$O"; do [ -f "$f" ] || { echo "NO_OUTPUT: $f absent"; exit 6; }; done
"$CEN" "$G" > "$OUT/g.cen" 2>/dev/null
"$CEN" "$O" > "$OUT/o.cen" 2>/dev/null
[ -s "$OUT/g.cen" ] && [ -s "$OUT/o.cen" ] || { echo "NO_OUTPUT: empty census"; exit 6; }
python3 "$(dirname "$0")/cells.py" "$OUT/g.cen" "$OUT/o.cen"
