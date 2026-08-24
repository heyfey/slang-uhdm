#!/bin/bash
# r10uvm121 — the assignment census over EVERY row-mode of a verify_golden
# workdir (measurement only).  Prints one block per database.
#   usage: cenall121.sh <workdir> <outdir> [name ...]
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
for mode in default testflags; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d"); n=${n%-*}
    if [ $# -gt 0 ]; then
      hit=0; for w in "$@"; do [ "$w" = "$n" ] && hit=1; done
      [ $hit -eq 1 ] || continue
    fi
    O=$d/slang.uhdm
    C=$d/cmds.txt
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "== $n/$mode SKIP-NOFILE"; continue
    fi
    "$HERE/ct121cen" "$G" > "$OUT/$n.$mode.g.tsv" 2>/dev/null; gr=$?
    "$HERE/ct121cen" "$O" > "$OUT/$n.$mode.o.tsv" 2>/dev/null; orc=$?
    echo "== $n/$mode  (rc g=$gr o=$orc  rows $(wc -l < "$OUT/$n.$mode.g.tsv") / $(wc -l < "$OUT/$n.$mode.o.tsv"))"
    python3 "$HERE/cen121.py" "$OUT/$n.$mode.g.tsv" "$OUT/$n.$mode.o.tsv"
  done
done
