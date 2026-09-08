#!/bin/bash
# r10uvm221repro/score221.sh — score every grid arm-view with cen221.py.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole acceptance judge.
#
#   usage: score221.sh <grid-outdir>
#
# CALIBRATION FIRST (RESUME §9's census trap): every holder is scored
# GOLDEN-vs-GOLDEN before it is scored golden-vs-ours, and a non-null
# calibration is printed as CALIB-DIRTY.  The `elab` column varies the GOLDEN
# only — the arm's own database is the one our binary writes without
# `--elabuhdm`, exactly as grid218.sh/grid220.sh do it.
set -u
OUT=${1:?grid-outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -d "$OUT" ] || { echo "FATAL: no grid outdir $OUT"; exit 3; }

# arm : holder-prefix ...
ARMS=(
  "a1_ctx:work@if221u:work@if221i:work@m221"
  "a2_home:work@ifh221u:work@ifh221i"
  "a3_muststay:s221:work@m221un:work@pr221un:work@pr221in:work@tops221"
  "a4_corpus:work@sv221_if"
  "a5_r5mix:work@ifr221u:work@ifr221i"
)
for row in "${ARMS[@]}"; do
  arm=${row%%:*}; pres=${row#*:}
  for view in parse elab; do
    G=$OUT/$arm.$view.golden.dump
    O=$OUT/$arm.ours.dump
    [ -f "$G" ] || { echo "FATAL: no $G"; exit 3; }
    [ -f "$O" ] || { echo "FATAL: no $O"; exit 3; }
    IFS=':' read -ra P <<< "$pres"
    for pre in "${P[@]}"; do
      c=$(python3 "$HERE/cen221.py" "$G" "$G" "$pre" --quiet | tail -1)
      case "$c" in
        *"MISSING-OURS=0 EXTRA-OURS=0 OTHER=0"*) cal=CALIB-NULL ;;
        *) cal="CALIB-DIRTY[$c]" ;;
      esac
      echo "== $arm/$view $pre $cal"
      python3 "$HERE/cen221.py" "$G" "$O" "$pre"
      echo "   enum-only: $(python3 "$HERE/cen221.py" "$G" "$O" "$pre" --quiet --enum-only | tail -1)"
    done
  done
done
