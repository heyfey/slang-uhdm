#!/usr/bin/env bash
# r10vrgg11 boundary — compile EVERY source arm (SUBDIRECTORIES INCLUDED) of the
# named repro dirs with TWO binaries and compare the databases byte-wise.
#   usage: bnd.sh <binA> <binB> <outfile> <dir> [<dir> ...]
# GUARDS: the file list is read on FD 3 (a stdin list gets swallowed by the
# first child); every child gets </dev/null; UNCOMPILABLE and ASYMMETRY are
# printed and COUNTED; PROCESSED is asserted against LISTED.
set -u
A=${1:?binA}; B=${2:?binB}; OUT=${3:?out}; shift 3
LIST=$(mktemp /tmp/vrgg11_bndlist.XXXXXX)
for d in "$@"; do
  [ -d "$d" ] || { echo "MISSING-DIR $d" >> "$OUT.miss"; continue; }
  find "$d" -type f \( -name '*.sv' -o -name '*.v' \) >> "$LIST"
done
sort -o "$LIST" "$LIST"
listed=$(wc -l < "$LIST")
same=0; mov=0; nocomp=0; asym=0; n=0
{
while IFS= read -r f <&3; do
  n=$((n+1))
  wa=$(mktemp -u /tmp/vrgg11_bnd_a.XXXXXX.uhdm)
  wb=$(mktemp -u /tmp/vrgg11_bnd_b.XXXXXX.uhdm)
  ( cd "$(dirname "$f")" && "$A" "$(basename "$f")" --single-unit -o "$wa" >/dev/null 2>&1 </dev/null )
  ra=$?
  ( cd "$(dirname "$f")" && "$B" "$(basename "$f")" --single-unit -o "$wb" >/dev/null 2>&1 </dev/null )
  rb=$?
  if   [ ! -f "$wa" ] && [ ! -f "$wb" ]; then echo "UNCOMPILABLE $f (rc $ra/$rb)"; nocomp=$((nocomp+1))
  elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then echo "ASYMMETRY $f (A rc=$ra B rc=$rb)"; asym=$((asym+1))
  elif cmp -s "$wa" "$wb"; then same=$((same+1))
  else echo "MOVER $f"; mov=$((mov+1)); fi
  rm -f "$wa" "$wb"
done 3< "$LIST"
echo "-- LISTED=$listed PROCESSED=$n identical=$same MOVERS=$mov uncompilable=$nocomp asymmetries=$asym"
[ "$listed" = "$n" ] || echo "FATAL: PROCESSED != LISTED"
} > "$OUT" 2>&1
rm -f "$LIST"
tail -2 "$OUT"
