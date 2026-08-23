#!/usr/bin/env bash
# r10buvm28: REUSED from r10buvm27 cen27.sh (paths re-pointed).
# r10buvm27 CENSUS runner — MEASUREMENT ONLY.
#   ./cen95.sh <sweep workdir root> <outdir>
# For every cell that has BOTH a golden (named in cmds.txt) and a slang.uhdm,
# runs ct95cen on each and writes <outdir>/<mode>_<test>.{g,o}
set -u
WD=${1:?workdir}; OUT=${2:?outdir}
CEN=${CEN:-/tmp/r10buvm28_ct28cen}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
mkdir -p "$OUT" || exit 9
n=0; miss=0
while read -r c; do
  d=$(dirname "$c")
  rel=${d#$WD/}
  key=$(echo "$rel" | tr '/' '_')
  g=$(grep -oE '/home/[^ )]*slang-uhdm-goldens/[0-9a-f]+' "$c" | head -1)/golden.uhdm
  o="$d/slang.uhdm"
  if [ ! -f "$g" ] || [ ! -f "$o" ]; then miss=$((miss+1)); continue; fi
  "$CEN" "$g" > "$OUT/$key.g" 2>/dev/null
  "$CEN" "$o" > "$OUT/$key.o" 2>/dev/null
  n=$((n+1))
done < <(find "$WD" -name cmds.txt | sort)
echo "CENSUS cells=$n skipped=$miss out=$OUT"
