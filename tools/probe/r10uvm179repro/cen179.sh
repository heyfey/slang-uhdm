#!/usr/bin/env bash
# r10uvm179repro/cen179.sh — THE CORPUS CENSUS.  MEASUREMENT ONLY; the official
# `uhdm-cmp` is the sole judge of equality.
#
#   cen179.sh <verify_golden workdir> <ct179cen> <out.txt> [name ...]
# Set CENFLAGS=--face for the whole-corpus run (the LAW'S FACE only); leave it
# empty for the nine UVM row-modes (every family, every reference).
# The ROW is folded INTO THE KEY (`FAM|G|<mode>/<row>|...`) so score179.py,
# which drops the producer tag, cannot merge two databases' cells.
#
# For every database in the workdir (or only the named rows), runs ct179cen on
# BOTH SIDES — the golden read out of the row's OWN cmds.txt (so the census can
# never silently score against the wrong golden, and the cache DIRECTORY is
# turned into .../golden.uhdm) and our slang.uhdm — and tags each row
# `<mode>/<name>`.  A row missing either side prints SKIP and is COUNTED: a
# driver that reaches nothing must never read as perfection.
set -u
WD=${1:?workdir}; CEN=${2:?ct179cen}; OUT=${3:?out}
shift 3
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL: no census binary $CEN"; exit 3; }
: > "$OUT"
skip=0; did=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    b=$(basename "$d"); n=${b%-*}
    if [ "$#" -gt 0 ]; then
      hit=0
      for want in "$@"; do [ "$n" = "$want" ] && hit=1; done
      [ "$hit" = 1 ] || continue
    fi
    O=$d/slang.uhdm
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP $mode/$n g=${G:-none}" >&2; skip=$((skip+1)); continue
    fi
    "$CEN" "$G" "G|$mode/$n" ${CENFLAGS:-} >> "$OUT" 2>>"$OUT.err"
    "$CEN" "$O" "O|$mode/$n" ${CENFLAGS:-} >> "$OUT" 2>>"$OUT.err"
    did=$((did+1))
  done
done
echo "-- databases=$did SKIP=$skip rows=$(wc -l < "$OUT")"
