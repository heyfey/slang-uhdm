#!/usr/bin/env bash
# r10buvm17repro/detcheck17.sh — DETERMINISM of one binary on one input.
# The campaign documents a per-invocation ORDER COIN on some rows (svunit_pkg's
# vpiTaskFunc listing, macro-buffer SourceLocation ordering under slang's
# parallel parse); a mover attribution is only readable where the input is
# byte-deterministic, so this asserts it for the row this pass moves.
#
#   usage: detcheck17.sh <binary> <source.sv> [n]
set -u
B=${1:?binary}; SRC=${2:?source}; N=${3:-3}
[ -x "$B" ] || { echo "FATAL no binary $B"; exit 3; }
[ -f "$SRC" ] || { echo "FATAL no source $SRC"; exit 3; }
W=$(mktemp -d /tmp/r10buvm17_det_XXXXXX)
no=0
for i in $(seq 1 "$N"); do
  "$B" "$SRC" --single-unit -o "$W/o$i.uhdm" > "$W/l$i.log" 2>&1
  [ -s "$W/o$i.uhdm" ] || { no=$((no+1)); continue; }
  md5sum "$W/o$i.uhdm" | cut -d' ' -f1 >> "$W/hashes"
done
echo "runs=$N NO_OUTPUT=$no distinct=$(sort -u "$W/hashes" 2>/dev/null | wc -l)"
sort "$W/hashes" 2>/dev/null | uniq -c
rm -rf "$W"
