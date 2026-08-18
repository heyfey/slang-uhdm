#!/usr/bin/env bash
# r10rgg11/run_grid11.sh — compile every grid cell with BOTH tools and read the
# PORT-ACTUAL census out of each database.
#   usage: run_grid11.sh <griddir> <slang-uhdm binary> <outdir> [suffix]
# GUARDS: both rc values recorded per cell; NODB / NOSLANG printed and COUNTED
# (a driver that reaches nothing must never read as perfection).
set -u
G=${1:?griddir}
BIN=${2:?slang binary}
O=${3:?outdir}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10rgg11_pcensus
[ -x "$BIN" ] || { echo "FATAL: no $BIN"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
mkdir -p "$O"
: > "$O/status.txt"
D=$(cd "$(dirname "$0")" && pwd)
ls -d "$G"/*/ | xargs -P 2 -I{} "$D/cell11.sh" {} "$O" "$BIN" "$SURELOG" "$CEN" >> "$O/status.txt"
echo "-- cells=$(wc -l < "$O/status.txt")  OK=$(grep -c ' OK ' "$O/status.txt"; true)  NODB=$(grep -c ' NODB ' "$O/status.txt"; true)  NOSLANG=$(grep -c ' NOSLANG ' "$O/status.txt"; true)"
