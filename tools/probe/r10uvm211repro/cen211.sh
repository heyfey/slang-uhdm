#!/usr/bin/env bash
# r10uvm211repro/cen211.sh — the CORPUS census over the named row-modes.
# MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
#
#   CEN=<ct211cen> cen211.sh <pristine workdir> <patched workdir> <outdir> [rows…]
#
# For each row-mode it runs `ct211cen --raw` twice against the SAME golden —
# golden-vs-PRISTINE and golden-vs-PATCHED — plus a golden-vs-GOLDEN
# CALIBRATION first (RESUME.md §9), and scores all three with score211.py.
# A row with no golden is reported SKIP-NOFILE, never silently skipped.
#
# WHY NOT A WHOLE-DUMP DIFF ALONE.  `uhdm-dump` does not print
# `vpiTypedefAlias` (r10uvm205's recorded instrument fact), so the order-blind
# dump diff sees only the OBJECT half of this family — here the minted arrays
# and element refs — and never the ALIAS half.  The census reads
# `Typedef_alias` explicitly and is the attribution instrument for that half;
# both halves are reported.
set -u
PW=${1:?pristine workdir}; QW=${2:?patched workdir}; OUT=${3:?outdir}
shift 3
ROWS=${*:-SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen}
CEN=${CEN:?set CEN to the built ct211cen}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
for t in $ROWS; do
  for mode in default testflags; do
    pd=$(ls -d "$PW/$mode/$t"-* 2>/dev/null | head -1)
    qd=$(ls -d "$QW/$mode/$t"-* 2>/dev/null | head -1)
    if [ -z "$pd" ] || [ -z "$qd" ]; then echo "$t,$mode SKIP-NODIR"; continue; fi
    g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$pd/cmds.txt" | head -1)
    g="$g/golden.uhdm"
    if [ ! -f "$g" ] || [ ! -f "$pd/slang.uhdm" ] || [ ! -f "$qd/slang.uhdm" ]; then
      echo "$t,$mode SKIP-NOFILE(g=$g)"; continue
    fi
    "$CEN" "$g" "$g"              --raw > "$OUT/$t.$mode.g.txt" 2>/dev/null
    "$CEN" "$g" "$pd/slang.uhdm"  --raw > "$OUT/$t.$mode.a.txt" 2>/dev/null
    "$CEN" "$g" "$qd/slang.uhdm"  --raw > "$OUT/$t.$mode.b.txt" 2>/dev/null
    printf "%-14s %-9s calib  " "$t" "$mode"
    python3 "$HERE/score211.py" "$OUT/$t.$mode.g.txt" "$OUT/$t.$mode.g.txt"
    printf "%-14s %-9s SCORE  " "$t" "$mode"
    python3 "$HERE/score211.py" "$OUT/$t.$mode.a.txt" "$OUT/$t.$mode.b.txt"
  done
done
