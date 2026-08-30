#!/usr/bin/env bash
# r10uvm163 — write the six ct163cen listings an arm workdir needs, then score
# them with cells163.py.  MEASUREMENT ONLY.
#   usage: CT163CEN=<bin> armcen163.sh <armdir> [<name-regex>]
# GUARD: every one of the six databases is existence-checked and a missing one
# is printed and COUNTED, so a scorer cannot read as clean on a workdir the arm
# driver never filled.
set -u
D=${1:?armdir}; PAT=${2:-}
CEN=${CT163CEN:?set CT163CEN}
[ -x "$CEN" ] || { echo "FATAL: no ct163cen at $CEN"; exit 3; }
miss=0
for s in g o q ge oe qe; do
  if [ -f "$D/$s.uhdm" ]; then
    "$CEN" --all "$D/$s.uhdm" > "$D/$s.cen" 2>&1
  else
    echo "MISSING-DB $D/$s.uhdm"; miss=$((miss+1)); rm -f "$D/$s.cen"
  fi
done
echo "-- databases-missing=$miss"
python3 "$(dirname "$0")/cells163.py" "$D" ${PAT:+"$PAT"}
