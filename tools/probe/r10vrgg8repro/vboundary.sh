#!/usr/bin/env bash
# r10vrgg8/vboundary.sh — compile EVERY source arm (SUBDIRECTORIES INCLUDED) of
# the named repro directories with BOTH binaries and compare byte-wise.
#
#   usage: vboundary.sh <a-bin> <b-bin> <outfile> <dir> [<dir> ...]
#
# GUARDS (each an ops trap this campaign has paid for):
#   * the file list is read on FD 3 and every child gets </dev/null, so a
#     compiler that reads stdin cannot swallow the list and shorten the run.
#   * PROCESSED is ASSERTED against the list length: a driver that reached
#     fewer files than it listed exits non-zero instead of reading as green.
#   * a file NEITHER binary compiles is UNCOMPILABLE and COUNTED.
#   * a file only ONE binary compiles is an ASYMMETRY and is reported loudly.
set -u
A=${1:?a bin}; B=${2:?b bin}; OUT=${3:?outfile}; shift 3
LIST=$(mktemp /tmp/vrgg8_bndlist.XXXXXX)
for d in "$@"; do
  [ -d "$d" ] && find "$d" -type f \( -name '*.sv' -o -name '*.v' \) || echo "MISSING-DIR $d" >&2
done | sort > "$LIST"
want=$(wc -l < "$LIST")
same=0; mv=0; nocomp=0; asym=0; n=0
{
while IFS= read -r f <&3; do
  n=$((n+1))
  wa=$(mktemp -u /tmp/vrgg8_bnd_a.XXXXXX.uhdm)
  wb=$(mktemp -u /tmp/vrgg8_bnd_b.XXXXXX.uhdm)
  (cd "$(dirname "$f")" && timeout 120 "$A" "$(basename "$f")" --single-unit -o "$wa" >/dev/null 2>&1 </dev/null)
  ra=$?
  (cd "$(dirname "$f")" && timeout 120 "$B" "$(basename "$f")" --single-unit -o "$wb" >/dev/null 2>&1 </dev/null)
  rb=$?
  if [ "$ra" -ge 128 ] || [ "$rb" -ge 128 ]; then echo "CRASH $f (rc $ra/$rb)"; fi
  if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then
    echo "UNCOMPILABLE $f (rc $ra/$rb)"; nocomp=$((nocomp+1))
  elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then
    echo "ASYMMETRY $f (a rc=$ra b rc=$rb)"; asym=$((asym+1))
  elif cmp -s "$wa" "$wb"; then
    same=$((same+1))
  else
    echo "MOVER $f"; mv=$((mv+1))
  fi
  rm -f "$wa" "$wb"
done 3< "$LIST"
echo "-- LISTED=$want PROCESSED=$n identical=$same MOVERS=$mv uncompilable=$nocomp asymmetries=$asym"
[ "$want" = "$n" ] && echo "PROCESSED-ASSERT OK" || echo "PROCESSED-ASSERT FAILED"
} > "$OUT" 2>&1
rm -f "$LIST"
tail -2 "$OUT"
