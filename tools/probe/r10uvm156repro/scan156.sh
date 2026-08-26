#!/usr/bin/env bash
# r10uvm156 — run ct156cen over the golden AND ours database of NAMED rows of a
# verify_golden workdir.  MEASUREMENT ONLY; the golden path is read out of the
# workdir's own cmds.txt and a missing side prints SKIP-NOFILE and is counted.
# MEASUREMENT ONLY.  LHS is ALWAYS golden.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
CEN=${CEN:?set CEN}
mkdir -p "$OUT"
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then echo "SKIP-NOFILE $n $mode"; continue; fi
      "$CEN" "$G" --tag=G > "$OUT/$n.$mode.G.txt" 2>&1
      "$CEN" "$O" --tag=O > "$OUT/$n.$mode.O.txt" 2>&1
      echo "OK $n $mode G=$(grep -c ' CT ' "$OUT/$n.$mode.G.txt"; true) O=$(grep -c ' CT ' "$OUT/$n.$mode.O.txt"; true)"
    done
  done
done
