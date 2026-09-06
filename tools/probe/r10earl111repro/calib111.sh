#!/usr/bin/env bash
# r10earl111 -- THE CENSUS CALIBRATION.  cen111 + cen111.py run GOLDEN vs
# GOLDEN: an instrument that cannot read zero on identical inputs cannot be
# trusted to read zero on a change (RESUME.md section 9: "Calibrate
# golden-vs-golden FIRST").
#   usage: calib111.sh <golden.uhdm> [<golden2.uhdm> ...]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
for G in "$@"; do
  [ -s "$G" ] || { echo "SKIP (missing) $G"; continue; }
  t=$(mktemp); "$HERE/cen111" "$G" > "$t" 2>/dev/null
  tail -1 "$t" | grep -q '^CENRC 0$' || { echo "CENFAIL $G"; rm -f "$t"; continue; }
  echo "== $G"
  python3 "$HERE/cen111.py" "$t" "$t" | sed -n '1,3p'
  rm -f "$t"
done
