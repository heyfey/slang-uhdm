#!/usr/bin/env bash
# r10rgg13repro/tfslice13.sh — the TESTFLAGS slice of a uhdm2rtlil sweep CSV, in
# the exact byte form the committed results/gate_uhdm2rtlil.csv uses (that
# baseline is TESTFLAGS-ONLY).  Written with awk, not python's csv.writer, whose
# default '\r\n' line terminator made a byte-identical slice read as 731
# differing rows.
set -u
IN=${1:?in csv}; OUT=${2:?out csv}
head -1 "$IN" > "$OUT"
awk -F, 'NR>1 && $2=="testflags"' "$IN" >> "$OUT"
echo "rows=$(( $(wc -l < "$OUT") - 1 )) -> $OUT"
