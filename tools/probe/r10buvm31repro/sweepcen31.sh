#!/usr/bin/env bash
# r10buvm31 — census sweep over an ENTIRE control workdir: for every test/mode
# that has BOTH our slang.uhdm and a golden cache entry, run the VAR census on
# each side.  MEASUREMENT ONLY.
#   sweepcen.sh <workdir root> <out dir> <cen bin>
set -u
ROOT=$1; OUT=$2; CEN=$3
mkdir -p "$OUT"
: > "$OUT/index.txt"
find "$ROOT" -name cmds.txt | sort | while read -r c; do
  d=$(dirname "$c")
  rel=${d#$ROOT/}
  o="$d/slang.uhdm"
  g=$(ugrep -o 'golden cache hit [^)]*' "$c" | head -1 | sed 's/golden cache hit //')
  [ -n "$g" ] && g="$g/golden.uhdm"
  key=$(echo "$rel" | tr '/' '_')
  if [ -f "$o" ]; then "$CEN" "$o" "O:$rel" > "$OUT/o.$key.txt" 2>/dev/null; fi
  if [ -n "$g" ] && [ -f "$g" ]; then "$CEN" "$g" "G:$rel" > "$OUT/g.$key.txt" 2>/dev/null; fi
  echo "$rel|$o|$g" >> "$OUT/index.txt"
done
echo "DONE $(ugrep -c . "$OUT/index.txt")"
