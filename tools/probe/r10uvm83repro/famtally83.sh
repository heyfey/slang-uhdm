#!/usr/bin/env bash
# r10uvm83 — the family tally of ONE ctladder ladder file, and the FIRST rung
# index of each family.  MEASUREMENT-ONLY; ctladder itself is unmodified and
# uhdm-cmp remains the sole judge.
#
#   usage: famtally83.sh <ladder.txt> [topN]
#
# GUARD: a file with no RUNG lines prints "NO RUNGS" and exits 4 — a ladder that
# recorded nothing must never read as "no families left".
set -u
F=${1:?ladder file}
N=${2:-8}
[ -f "$F" ] || { echo "FATAL: no $F"; exit 3; }
n=$(grep -c '^RUNG' "$F" || true)
[ "$n" -gt 0 ] || { echo "NO RUNGS in $F"; exit 4; }
echo "== $(basename "$F")  rungs=$n"
grep '^RUNG' "$F" | sed -E 's/.*\tFAM=([^\t]*).*/\1/' | sort | uniq -c | sort -rn |
head -"$N" | while read -r c fam; do
  first=$(grep -n '^RUNG' "$F" | grep -m1 -F "FAM=$fam" | sed -E 's/^[0-9]+:RUNG\t([0-9]+).*/\1/')
  printf "%6d  [R%s]  %s\n" "$c" "${first:-?}" "$fam"
done
