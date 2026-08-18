#!/usr/bin/env bash
# r10vrgg11 grid runner: <griddir> <binary> <outdir> <tag>
set -u
G=${1:?}; BIN=${2:?}; O=${3:?}; TAG=${4:?}
[ -x "$BIN" ] || { echo "FATAL no $BIN"; exit 3; }
mkdir -p "$O"; : > "$O/status_$TAG.txt"
ls -d "$G"/*/ 3< /dev/null | xargs -P 2 -I{} /tmp/vrgg11_cell.sh {} "$O" "$BIN" "$TAG" >> "$O/status_$TAG.txt"
echo "-- cells=$(wc -l < "$O/status_$TAG.txt") OK=$(grep -c ' OK ' "$O/status_$TAG.txt"; true) NODB=$(grep -c ' NODB ' "$O/status_$TAG.txt"; true) NOSLANG=$(grep -c ' NOSLANG ' "$O/status_$TAG.txt"; true)"
