#!/bin/bash
# v11u94 — run every grid arm (r11u106's five + this verifier's eight) with the
# pristine, r11u106 LAW and FIXED binaries and score each pair per cell by the
# NAME key (r11u106repro/score106.py).  Tags are the SAME LENGTH (byte-comparable).
# usage: grid94.sh <scratch dir> pris=<bin> lawx=<bin> fixx=<bin>   (TW106=<walker>)
set -u
G=${1:?scratch}; shift
H=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$G"; cp "$H"/r11u106repro/grid/*.sv "$H"/v11u94repro/grid/*.sv "$G"/
for a in "$G"/*.sv; do
  bash "$H"/r11u106repro/run106.sh "$a" "$@"
  n=${a%.sv}
  for t in lawx fixx; do
    [ -f "$n.$t.tw" ] && echo "SCORE $(basename $n) pris->$t $(python3 "$H"/r11u106repro/score106.py "$n.g.tw" "$n.pris.tw" "$n.$t.tw" | tail -1)"
  done
  [ -f "$n.fixx.tw" ] && echo "SCORE $(basename $n) lawx->fixx $(python3 "$H"/r11u106repro/score106.py "$n.g.tw" "$n.lawx.tw" "$n.fixx.tw" | tail -1)"
  [ -f "$n.fixx.tw" ] && echo "SWAP  $(basename $n) fixx->pris $(python3 "$H"/r11u106repro/score106.py "$n.g.tw" "$n.fixx.tw" "$n.pris.tw" | tail -1)"
done
