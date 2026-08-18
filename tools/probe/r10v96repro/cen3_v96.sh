#!/usr/bin/env bash
# r10v96 VERIFIER 3-way corpus census: golden / pristine / patched per cell.
set -u
WDP=${1:?patched wd}; WDR=${2:?pristine wd}; OUT=${3:?outdir}
CEN=${CEN:-/tmp/v96_ct96cen}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
rm -rf "$OUT"; mkdir -p "$OUT" || exit 9
n=0; miss=0
while read -r c; do
  d=$(dirname "$c"); rel=${d#$WDP/}; key=$(echo "$rel" | tr '/' '_')
  g=$(grep -oE '/home/[^ )]*slang-uhdm-goldens/[0-9a-f]+' "$c" | head -1)/golden.uhdm
  op="$d/slang.uhdm"; or="$WDR/$rel/slang.uhdm"
  if [ ! -f "$g" ] || [ ! -f "$op" ] || [ ! -f "$or" ]; then miss=$((miss+1)); continue; fi
  "$CEN" "$g"  > "$OUT/$key.g" 2>/dev/null
  "$CEN" "$op" > "$OUT/$key.p" 2>/dev/null
  "$CEN" "$or" > "$OUT/$key.r" 2>/dev/null
  n=$((n+1))
done < <(find "$WDP" -name cmds.txt | sort)
echo "CENSUS3 cells=$n skipped=$miss out=$OUT"
