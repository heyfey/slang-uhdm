#!/usr/bin/env bash
# r10rgg4/boundary.sh — re-run the COMMITTED grids this pass could disturb and
# require that only cells § sizeDimOvrChain4 NAMES move.
#
#   usage: BASE=<bin> PAT=<bin> ./boundary.sh
#
# Grids re-run:
#   r10rgg3repro  (37 interface-port-view range cells) + r10vrgg3repro (52)
#     -- the SAME code region: interface array port ranges.
#   r10earl49/51/52/55repro -- the fold-law family (adjustSize + typespec
#     PRESENCE laws on folded param constants).
# GUARD: a grid whose driver is missing prints NO-DRIVER and is COUNTED.
set -u
here=$(cd "$(dirname "$0")" && pwd)
P=$(cd "$here/.." && pwd)
bad=0
for g in r10rgg3repro r10vrgg3repro; do
  echo "======== $g"
  d=$P/$g
  drv=""
  [ -x "$d/score.sh" ] && drv=$d/score.sh
  [ -z "$drv" ] && [ -x "$d/score2.sh" ] && drv=$d/score2.sh
  if [ -z "$drv" ]; then echo "  NO-DRIVER"; bad=$((bad+1)); continue; fi
  [ -f "$d/gen_grid.py" ] && (cd "$d" && python3 gen_grid.py > /dev/null 2>&1)
  [ -f "$d/gen.py" ] && (cd "$d" && python3 gen.py > /dev/null 2>&1)
  cells=$(cd "$d" && ls -d */ 2>/dev/null | tr -d /)
  [ -z "$cells" ] && { echo "  NO-CELLS"; bad=$((bad+1)); continue; }
  (cd "$d" && BASE=${BASE:-} PAT=${PAT:-} "$drv" $cells 2>&1 | tail -60)
done
echo "PROBLEMS=$bad"
