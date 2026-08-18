#!/usr/bin/env bash
# r10rgg10/run_grid10.sh — compile every grid cell with BOTH tools and read the
# ELAB/DEF parameter census out of each database.
#
#   usage: run_grid10.sh <griddir> <slang-uhdm binary> <outdir>
#
# GUARDS: every cell records BOTH rc values; a cell whose Surelog run produced
# no database is printed NODB and COUNTED (a driver that reaches nothing must
# never read as perfection); a cell slang rejects is NOSLANG and COUNTED.
set -u
G=${1:?griddir}
BIN=${2:?slang binary}
O=${3:?outdir}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10rgg10_pcensus
[ -x "$BIN" ] || { echo "FATAL: no $BIN"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no $CEN"; exit 3; }
mkdir -p "$O"
: > "$O/status.txt"
D=$(cd "$(dirname "$0")" && pwd)
# NOTE: `</dev/null` belongs on the CHILD (inside cell10.sh), never on xargs —
# putting it here REPLACES the pipe and xargs reads no arguments at all, which
# is exactly how the first two runs of this grid measured cells=0.
ls -d "$G"/*/ | xargs -P 2 -I{} "$D/cell10.sh" {} "$O" "$BIN" "$SURELOG" "$CEN" >> "$O/status.txt"
echo "-- cells=$(wc -l < "$O/status.txt")  OK=$(grep -c ' OK ' "$O/status.txt"; true)  NODB=$(grep -c ' NODB ' "$O/status.txt"; true)  NOSLANG=$(grep -c ' NOSLANG ' "$O/status.txt"; true)"
