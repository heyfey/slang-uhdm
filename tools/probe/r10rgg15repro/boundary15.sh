#!/usr/bin/env bash
# r10rgg15/boundary15.sh (carried from r10rgg9 via r10rgg11) — compile EVERY source arm of the named precedent repro
# directories with BOTH binaries and compare the databases byte-wise.
#
#   usage: boundary.sh <base-bin> <pat-bin> <outfile> <repro-dir> [<repro-dir> ...]
#
# GUARDS (each an ops trap this campaign has paid for):
#   * SUBDIRECTORY arms are compiled too (`find`, not a top-level glob) -- a
#     boundary that only compiles the top level tests almost none of the grid.
#   * a file NEITHER binary can compile is UNCOMPILABLE and COUNTED, never
#     silently skipped, so a driver that reaches nothing cannot read as green.
#   * a file only ONE binary compiles is an ASYMMETRY and is reported loudly.
set -u
A=${1:?base bin}; B=${2:?pat bin}; OUT=${3:?outfile}; shift 3
same=0; diff=0; nocomp=0; asym=0; n=0
{
for d in "$@"; do
  [ -d "$d" ] || { echo "MISSING-DIR $d"; continue; }
  while IFS= read -r f; do
    n=$((n+1))
    wa=$(mktemp -u /tmp/r10rgg15_bnd_a.XXXXXX.uhdm)
    wb=$(mktemp -u /tmp/r10rgg15_bnd_b.XXXXXX.uhdm)
    (cd "$(dirname "$f")" && "$A" "$(basename "$f")" --single-unit -o "$wa" >/dev/null 2>&1)
    ra=$?
    (cd "$(dirname "$f")" && "$B" "$(basename "$f")" --single-unit -o "$wb" >/dev/null 2>&1)
    rb=$?
    if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then
      echo "UNCOMPILABLE $f (rc $ra/$rb)"; nocomp=$((nocomp+1))
    elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then
      echo "ASYMMETRY $f (base rc=$ra pat rc=$rb)"; asym=$((asym+1))
    elif cmp -s "$wa" "$wb"; then
      same=$((same+1))
    else
      echo "MOVER $f"; diff=$((diff+1))
    fi
    rm -f "$wa" "$wb"
  done < <(find "$d" -type f \( -name '*.sv' -o -name '*.v' \) \
             -not -path '*/slpp_all/*' | sort)
done
echo "-- files=$n identical=$same MOVERS=$diff uncompilable=$nocomp asymmetries=$asym"
} > "$OUT" 2>&1
