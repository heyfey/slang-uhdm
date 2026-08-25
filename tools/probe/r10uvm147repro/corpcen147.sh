#!/usr/bin/env bash
# r10uvm147 — run ct147cen over golden AND ours for every row in a
# verify_golden workdir, then join.  MEASUREMENT-ONLY; LHS is always golden.
#   usage: [CEN=..] corpcen147.sh <workdir> <outdir> [name-regex]
# The golden path is read out of the row's OWN cmds.txt and the cache DIRECTORY
# is turned into .../golden.uhdm.  A missing side prints SKIP-NOFILE, counted.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; RE=${3:-.}
CEN=${CEN:-/tmp/r10uvm147_ct147cen}
JOIN=$(dirname "$(readlink -f "$0")")/join147.py
mkdir -p "$OUT"; miss=0; ok=0
for m in default testflags; do
  for d in "$WD/$m"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d"); n=${n%-*}
    echo "$n" | grep -qE "$RE" || continue
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    O=$d/slang.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP-NOFILE ${m}_${n}"; miss=$((miss+1)); continue
    fi
    "$CEN" "$G" --sel > "$OUT/${m}_${n}.g" 2>/dev/null
    "$CEN" "$O" --sel > "$OUT/${m}_${n}.o" 2>/dev/null
    printf "%-30s %s\n" "${m}_${n}" \
      "$(python3 "$JOIN" "$OUT/${m}_${n}.g" "$OUT/${m}_${n}.o" | tail -1)"
    ok=$((ok+1))
  done
done
echo "-- measured=$ok SKIP-NOFILE=$miss"
