#!/bin/bash
# r10uvm113 — run the ct113cen/cen113.py binding census over the NINE UVM
# row-modes of a verify_golden workdir.  MEASUREMENT ONLY.
#
#   usage: cenall113.sh <workdir> <outdir>
#
# The golden path is read out of each row's OWN cmds.txt (a driver must never
# pick its own golden), and a row whose golden or ours is missing prints
# SKIP-NOFILE and is COUNTED — uhdm-cmp and every tool here exit 0 on a missing
# input, so a driver that reaches nothing must not read as perfection.
set -u
WD=${1:?workdir}
OUT=${2:?outdir}
CEN=${CEN:-/tmp/r10uvm113_scratch/ct113cen}
# r10v113 FIX: without this the default path (this pass's own scratch) is absent
# on any other machine, ct113cen never runs, every census file is EMPTY and the
# join prints all-zero counts -- a driver that reaches nothing reading as
# perfection, which the measurement laws forbid.
[ -x "$CEN" ] || { echo "FATAL: no ct113cen at $CEN (build it and pass CEN=)"; exit 3; }
JOIN=${JOIN:-$(dirname "$0")/cen113.py}
mkdir -p "$OUT" || exit 1
skip=0; done_=0
for mode in default testflags; do
  for n in SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "SKIP-NOFILE $n/$mode"; skip=$((skip+1)); continue
      fi
      "$CEN" "$G" > "$OUT/$n.$mode.g.tsv" 2>"$OUT/$n.$mode.g.err"
      "$CEN" "$O" > "$OUT/$n.$mode.o.tsv" 2>"$OUT/$n.$mode.o.err"
      python3 "$JOIN" "$OUT/$n.$mode.g.tsv" "$OUT/$n.$mode.o.tsv" "$n/$mode" \
        > "$OUT/$n.$mode.join.txt"
      done_=$((done_+1))
    done
  done
done
echo "-- censused=$done_  SKIP-NOFILE=$skip"
