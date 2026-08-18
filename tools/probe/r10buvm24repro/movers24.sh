#!/usr/bin/env bash
# r10buvm24repro/movers24.sh — score every MOVER of a sweep pair against its OWN
# golden with the CALL census, three ways.  MEASUREMENT ONLY.
#
#   movers24.sh <pristine sl workdir> <patched sl workdir> <cen bin> <out> <name...>
set -u
P=$1; Q=$2; CEN=$3; OUT=$4; shift 4
mkdir -p "$OUT"
for n in "$@"; do
  for m in default testflags; do
    for d in "$P/$m/$n"-*/; do
      [ -d "$d" ] || continue
      qd="$Q/$m/$(basename "$d")"
      [ -f "$qd/slang.uhdm" ] || continue
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)/golden.uhdm
      [ -f "$G" ] || { echo "SKIP-NOGOLD $m/$n"; continue; }
      "$CEN" "$G"                 G > "$OUT/$m.$n.g.txt"  2>/dev/null
      "$CEN" "$d/slang.uhdm"      O > "$OUT/$m.$n.p.txt"  2>/dev/null
      "$CEN" "$qd/slang.uhdm"     O > "$OUT/$m.$n.q.txt"  2>/dev/null
      echo "== $m/$n"
      python3 "$(dirname "$0")/gridcmp24.py" "$OUT/$m.$n.g.txt" \
        "$OUT/$m.$n.p.txt" "$OUT/$m.$n.q.txt" --ms
    done
  done
done
