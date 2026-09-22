#!/usr/bin/env bash
# r11u101 grid driver: every grid under the six tags, each grid sequential over
# tags (rr98.sh regenerates the golden per arm per tag in the arm dir, so two
# tags must never share an arm dir at once), three grids at a time.
#   usage: PRIS=<pristine bin> LAW=<law bin> runall101.sh <grid-copy-dir>...
# Run it on COPIES of the committed grids (rr98.sh writes into the arm dirs).
set -u
PRIS=${PRIS:?pristine binary}; LAW=${LAW:?law binary}
RR=${RR:-$(cd "$(dirname "$0")/.." && pwd)/r11u98repro/rr98.sh}
export PRIS LAW RR
run_grid() {
  g=$1
  for spec in "pris|$PRIS|" "law2|$LAW|" "off2|$LAW|R11U101_OFF=1" \
              "aoff|$LAW|R11U101_NESTPORT_OFF=1" "boff|$LAW|R11U101_NESTKEY_OFF=1" \
              "soff|$LAW|R11U101_NESTSHADOW_OFF=1"; do
    IFS='|' read tag bin envs <<< "$spec"
    env $envs GRID=$g bash $RR $bin $tag > $g.$tag.txt 2>&1
  done
}
export -f run_grid
printf '%s\n' "$@" | xargs -P 3 -I{} bash -c 'run_grid {}'
