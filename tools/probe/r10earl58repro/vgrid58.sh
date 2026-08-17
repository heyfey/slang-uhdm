#!/usr/bin/env bash
# v58 VERIFIER — run every verifier arm (v58v*.sv) on THREE binaries and print
# the pristine->patched transition census for each parameter occurrence.
# LHS is ALWAYS golden (Surelog, -elabuhdm).  A cell that is SAME on the
# pristine side and DIFF on a patched side is a PRISTINE-RIGHT -> PATCHED-WRONG
# regression; the reverse is a gain.
#   usage: vgrid58.sh <pristine> <patchedA> [patchedB] [wdroot]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${1:?pristine}; PA=${2:?patched A}; PB=${3:-}
WD=${4:-/tmp/v58_vgrid}
mkdir -p "$WD" || exit 9
declare -A NM=( [v58v1]=W [v58v2]=L [v58v3]=FW,gi,CW,UW,NW,DA,SW,MW [v58v4]=IW,MP,PW,ML,TE,TU,TS,TB [v58v5]=L,MW [v58v6]=L [v58v7]=L )
for src in "$HERE"/v58v*.sv; do
  b=$(basename "$src" .sv); k=${b%%_*}
  for lab in pris A B; do
    case $lab in pris) BIN=$PRIS;; A) BIN=$PA;; B) BIN=$PB;; esac
    [ -n "$BIN" ] || continue
    SLANG_UHDM="$BIN" "$HERE/varm58e.sh" "$src" "$WD/${b}_$lab" >/dev/null 2>&1
  done
  echo "########## $b  (names ${NM[$k]:-L})"
  for lab in pris A B; do
    d="$WD/${b}_$lab"; [ -f "$d/o.dump" ] || continue
    echo "---- $lab"
    (cd "$d" && python3 "$HERE/grid58.py" "$src" g.dump o.dump "${NM[$k]:-L}" |
       awk '{printf "%s %s %s\n",$1,$2,$3}')
  done
done
