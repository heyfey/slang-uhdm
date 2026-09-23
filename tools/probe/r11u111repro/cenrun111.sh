#!/bin/bash
# cenrun111.sh <sweep-workdir> <out-dir> [tag]: cen111 on every row's golden (cache) and slang.uhdm.
# Writes <out-dir>/<mode>__<test>.{gold,<tag>} (sorted census lines).  Golden is censused once
# per row (skipped when present) -- run twice into a fresh dir for the calibration.
WD=${1:?}; OUT=${2:?}; TAG=${3:-ours}; CEN=${CEN:-/tmp/r11u111_tools/cen111}
mkdir -p "$OUT"
n=0
for c in $(find "$WD" -name cmds.txt | sort); do
  d=$(dirname "$c"); t=$(basename "$d"); m=$(basename "$(dirname "$d")"); k="${m}__${t%-*}"
  g=$(grep -o 'golden cache hit [^)]*' "$c" | awk '{print $4}')/golden.uhdm
  [ -f "$g" ] && [ ! -f "$OUT/$k.gold" ] && timeout 600 "$CEN" "$g" 2>/dev/null | sort > "$OUT/$k.gold"
  [ -f "$d/slang.uhdm" ] && timeout 600 "$CEN" "$d/slang.uhdm" 2>/dev/null | sort > "$OUT/$k.$TAG"
  n=$((n+1))
done
echo "ROWS=$n"
