#!/bin/bash
# cenrun108.sh <sweep-workdir> <out-file>: cen108 on every row's golden (cache) and slang.uhdm
# out lines: <mode>/<test> <gold|ours> <census line>
WD=${1:?}; OUT=${2:?}; CEN=${CEN:-/tmp/r11u108_tools/cen108}
: > "$OUT"
for c in $(find "$WD" -name cmds.txt | sort); do
  d=$(dirname "$c"); t=$(basename "$d"); m=$(basename "$(dirname "$d")")
  g=$(grep -o 'golden cache hit [^)]*' "$c" | awk '{print $4}')/golden.uhdm
  [ -f "$g" ] && timeout 300 "$CEN" "$g" 2>/dev/null | sed "s#^#$m/$t gold #" >> "$OUT"
  [ -f "$d/slang.uhdm" ] && timeout 300 "$CEN" "$d/slang.uhdm" 2>/dev/null | sed "s#^#$m/$t ours #" >> "$OUT"
done
echo "ROWS=$(find "$WD" -name cmds.txt | wc -l) LINES=$(wc -l < "$OUT")"
