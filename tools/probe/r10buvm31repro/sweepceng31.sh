#!/usr/bin/env bash
set -u
ROOT=$1; OUT=$2; CEN=$3
mkdir -p "$OUT"
find "$ROOT" -name cmds.txt | sort | while read -r c; do
  d=$(dirname "$c"); rel=${d#$ROOT/}
  g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$c" | head -1)
  [ -n "$g" ] || continue
  gg="$g/golden.uhdm"; [ -f "$gg" ] || continue
  key=$(echo "$rel" | tr '/' '_')
  "$CEN" "$gg" "G:$rel" > "$OUT/g.$key.txt" 2>/dev/null
done
echo "DONE g=$(ls "$OUT"/g.*.txt 2>/dev/null | wc -l)"
