#!/usr/bin/env bash
# r11u71 SHAPE CENSUS — every ELABORATED cont_assign that lives inside a
# generate scope, golden shape vs ours, over a whole sweep workdir, scored with
# the RESOLVING SHAPE LISTER (`shapes71.py`, section-scoped repeat resolution).
#
# Run the GOLDEN-vs-GOLDEN calibration FIRST (`SIDE=golden`): it must read 0
# differing cells, otherwise the instrument is reading noise and no census
# number below it means anything.
#
# A dump that outruns its budget writes a TIMEOUT-G / TIMEOUT-O row; it is
# never silently dropped, so a census zero cannot hide one.
#
# usage: census71.sh <workdir/mode-dir> <out.tsv> [golden]
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MD=${1:?mode dir}; OUT=${2:?out}; SIDE=${3:-ours}
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
TMO=${TMO:-45}
# The LISTER needs a budget of its OWN: a multi-hundred-megabyte dump parses for
# far longer than any dump budget, and an unbounded parse looks exactly like a
# census that finished.  A TIMEOUT-P row is RECORDED, never silently dropped.
PTMO=${PTMO:-90}
: > "$OUT"
for d in "$MD"/*/; do
  n=$(basename "$d")
  [ -f "$d/cmds.txt" ] || continue
  g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$d/cmds.txt" | head -1)
  [ -n "$g" ] || continue
  [ -f "$g/golden.uhdm" ] || continue
  if [ "$SIDE" = golden ]; then o=$g/golden.uhdm; else o=$d/slang.uhdm; fi
  [ -f "$o" ] || continue
  timeout "$TMO" "$DUMP" "$g/golden.uhdm" > "/tmp/r11u71_cg.$$" 2>/dev/null \
    || { printf '%s\tTIMEOUT-G\n' "$n" >> "$OUT"; continue; }
  timeout "$TMO" "$DUMP" "$o" > "/tmp/r11u71_co.$$" 2>/dev/null \
    || { printf '%s\tTIMEOUT-O\n' "$n" >> "$OUT"; continue; }
  r=$(NOSPAN=1 timeout "$PTMO" python3 "$HERE/shapes71.py" cmp \
        "/tmp/r11u71_cg.$$" "/tmp/r11u71_co.$$" 2>/dev/null | tail -1)
  [ -n "$r" ] || r='TIMEOUT-P'
  printf '%s\t%s\n' "$n" "$r" >> "$OUT"
done
rm -f "/tmp/r11u71_cg.$$" "/tmp/r11u71_co.$$"
awk -F'\t' '{print $2}' "$OUT" | grep -c 'DIFFERING=0' > /dev/null
echo "rows      $(wc -l < "$OUT")"
echo "TIMEOUT   $(grep -c TIMEOUT "$OUT"; true)"
echo "cells     $(sed -n 's/.*golden=\([0-9]*\).*/\1/p' "$OUT" | \
                 awk '{s+=$1} END{print s+0}')"
echo "DIFFERING $(sed -n 's/.*DIFFERING=\([0-9]*\).*/\1/p' "$OUT" | \
                 awk '{s+=$1} END{print s+0}')"
echo "tests with a differing cell $(grep -c 'DIFFERING=[1-9]' "$OUT"; true)"
