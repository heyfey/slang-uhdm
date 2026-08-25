#!/usr/bin/env bash
# r10uvm138 — CORPUS census: cen138 over every named row-mode of a
# verify_golden workdir, GOLDEN and OURS, then score138 the pair.
# The golden path is read from the row's OWN cmds.txt (never guessed).
#   usage: OUT=<dir> corpcen138.sh <workdir> <name> [<name>...]
set -u
WD=${1:?workdir}; shift
OUT=${OUT:?set OUT}; mkdir -p "$OUT"
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && G=$G/golden.uhdm
      if [ ! -f "$O" ] || [ ! -f "$G" ]; then echo "$n $mode SKIP-NOFILE"; continue; fi
      "$DUMP" "$G" 2>/dev/null | python3 "$HERE/cen138.py" - > "$OUT/$n.$mode.g.cen"
      "$DUMP" "$O" 2>/dev/null | python3 "$HERE/cen138.py" - > "$OUT/$n.$mode.o.cen"
      echo "$n $mode gcells=$(wc -l < "$OUT/$n.$mode.g.cen") ocells=$(wc -l < "$OUT/$n.$mode.o.cen")"
    done
  done
done
