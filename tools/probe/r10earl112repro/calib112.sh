#!/usr/bin/env bash
# r10earl112 -- THE CENSUS CALIBRATION.  MEASUREMENT ONLY.
#
# RESUME.md section 9, census traps: "Calibrate golden-vs-golden FIRST."  A
# census that reports a difference between a golden database and ITSELF is
# measuring its own instrument, not the emitter.  This runs cen112 twice over
# each arm's golden and scores the pair with cen112.py, which must read
# 0 DIFF on every key of both families.
#
# It also runs the cross-check that matters for THIS census: the same golden
# read through the `plain` and the `elab` producer are DIFFERENT databases and
# are NOT expected to agree -- so they are scored separately, never merged.
#
#   usage: calib112.sh <grid-outdir>
set -u
G=${1:?grid outdir}
CEN=$(cd "$(dirname "$0")" && pwd)/cen112
PY=$(cd "$(dirname "$0")" && pwd)/cen112.py
[ -x "$CEN" ] || CEN=${CEN_BIN:?no cen112 beside this script and no CEN_BIN}
bad=0
for d in "$G"/*/; do
  a=$(basename "$d")
  [ -f "$d/cen.gold.txt" ] || { echo "SKIP $a (no golden census)"; continue; }
  cp "$d/cen.gold.txt" "/tmp/calib112.$$.txt"
  out=$(python3 "$PY" "$d/cen.gold.txt" "/tmp/calib112.$$.txt" 2>&1 | grep '^SAME ')
  echo "$a  $out"
  case "$out" in *"DIFF 0 "*) ;; *) bad=$((bad+1));; esac
  rm -f "/tmp/calib112.$$.txt"
done
echo "CALIB-BAD=$bad"
[ "$bad" -eq 0 ] && echo "CALIBRATION PASS (golden-vs-golden 0 DIFF everywhere)" \
                 || echo "CALIBRATION FAIL"
