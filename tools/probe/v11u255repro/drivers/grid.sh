#!/bin/bash
# v11u255 grid.sh <out>: every case under ../cases in both views on the seven configurations of
# r11u255repro/drivers/grid.sh (pristine, law, R11U255_OFF, each R11U255_<LAW>_OFF); every line carries rc=.
D=$(cd "$(dirname "$0")" && pwd); . "$D/env.sh" || exit 2
bash "$R255D/grid.sh" "$1" $(find "$D/../cases" -mindepth 2 -maxdepth 2 -type d | sort | grep -vwE "$FENCE_RE")
python3 "$R255D/gridsum.py" "$1"
