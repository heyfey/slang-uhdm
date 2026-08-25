#!/bin/bash
# r10uvm149 — score one grid run's arms with cen149.py (golden vs pristine and
# golden vs patched), plus the golden-vs-golden CALIBRATION.  MEASUREMENT ONLY.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#   usage: score149.sh <grid-workdir> <cen149.py>
set -u
W=${1:?grid workdir}; PY=${2:?cen149.py}
for d in "$W"/*/; do
  a=$(basename "$d")
  [ -f "$d/cen.sl.txt" ] || continue
  echo "===== $a  (CALIBRATION golden-vs-golden)"
  python3 "$PY" "$d/cen.sl.txt" "$d/cen.sl.txt" | sed 's/^/  /'
  echo "----- $a  PRISTINE"
  python3 "$PY" "$d/cen.sl.txt" "$d/cen.pris.txt" | sed 's/^/  /'
  echo "----- $a  PATCHED"
  python3 "$PY" "$d/cen.sl.txt" "$d/cen.pat.txt" | sed 's/^/  /'
done
