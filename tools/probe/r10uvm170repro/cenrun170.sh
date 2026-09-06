#!/usr/bin/env bash
# r10uvm170repro/cenrun170.sh — THE CORPUS CENSUS.  MEASUREMENT ONLY.
#
#   cenrun170.sh <pristine-workdir> <patched-workdir> <outdir> [name-filter]
#
# For EVERY row that has BOTH a golden and a slang database in BOTH workdirs it
# writes three `ct170cen --casts` listings (golden / pristine / patched) plus a
# `--unsup` listing, so `join170.py` can score every written cast target in the
# corpus, one-sided sets included.  The golden path is read out of each row's
# OWN cmds.txt (never guessed), and every rc is recorded.
set -u
WA=${1:?pristine workdir}; WB=${2:?patched workdir}; OUT=${3:?outdir}
FILT=${4:-}
CEN=${CT170CEN:?set CT170CEN}
mkdir -p "$OUT"; : > "$OUT/rows.txt"; : > "$OUT/skip.txt"
n=0
for mode in default testflags; do
  for d in "$WA/$mode"/*/; do
    [ -d "$d" ] || continue
    row=$(basename "$d")
    [ -n "$FILT" ] && { echo "$row" | grep -qE "$FILT" || continue; }
    A=$d/slang.uhdm
    B=$WB/$mode/$row/slang.uhdm
    C=$d/cmds.txt
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$A" ] || [ ! -f "$B" ]; then
      echo "SKIP $mode/$row g=${G:-none} a=$([ -f "$A" ] && echo y || echo n) b=$([ -f "$B" ] && echo y || echo n)" >> "$OUT/skip.txt"
      continue
    fi
    tag="$mode.$row"
    "$CEN" "$G" --casts > "$OUT/$tag.g.casts" 2>/dev/null; rg=$?
    "$CEN" "$A" --casts > "$OUT/$tag.a.casts" 2>/dev/null; ra=$?
    "$CEN" "$B" --casts > "$OUT/$tag.b.casts" 2>/dev/null; rb=$?
    "$CEN" "$G" --unsup > "$OUT/$tag.g.unsup" 2>/dev/null
    "$CEN" "$B" --unsup > "$OUT/$tag.b.unsup" 2>/dev/null
    echo "$tag rc=$rg/$ra/$rb" >> "$OUT/rows.txt"
    n=$((n+1))
  done
done
echo "ROWS=$n SKIPPED=$(wc -l < "$OUT/skip.txt")"
