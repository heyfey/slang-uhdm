#!/usr/bin/env bash
# r10uvm182repro/cenall182.sh — the CORPUS CENSUS over named rows of a
# verify_golden workdir: every `hier_path` element's `vpiActual`, golden against
# ours, both one-sided sets.  MEASUREMENT ONLY.
#   cenall182.sh <workdir> <outdir> <name> [<name> ...]
# The golden is read out of each test's OWN cmds.txt (never guessed), a missing
# side prints SKIP-NOFILE and is COUNTED, and the header count is asserted
# against the joins reported — a census that reached nothing must not read as
# perfection.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
HERE=$(cd "$(dirname "$0")" && pwd)
CEN=$HERE/ct182cen
[ -x "$CEN" ] || { echo "FATAL: build ct182cen first"; exit 3; }
mkdir -p "$OUT" || exit 1
n=0; miss=0
for name in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$name"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "SKIP-NOFILE $name/$mode"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G" > "$OUT/$name.$mode.g.cen" 2>/dev/null
      "$CEN" "$O" > "$OUT/$name.$mode.o.cen" 2>/dev/null
      printf '%-16s %-9s ' "$name" "$mode"
      python3 "$HERE/cenjoin182.py" "$OUT/$name.$mode.g.cen" \
                                    "$OUT/$name.$mode.o.cen"
      n=$((n+1))
    done
  done
done
echo "-- joined=$n  SKIP-NOFILE=$miss"
