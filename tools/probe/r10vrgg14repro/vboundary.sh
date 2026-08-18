#!/usr/bin/env bash
# r10vrgg14 verifier boundary — per-FILE and per-DIRECTORY arms, from a COPY of
# the probe tree, with every ops-trap guard the campaign has paid for:
#   * file list read on fd 3, children `</dev/null` ON THE CHILD;
#   * PROCESSED asserted == LISTED (a driver that reaches nothing cannot read
#     green);
#   * rc recorded per cell; UNCOMPILABLE and ASYMMETRY counted, never skipped;
#   * scratch keyed on the RELATIVE path (duplicate basenames exist).
#   usage: vboundary.sh <binA> <binB> <outfile> <root> [<root> ...]
set -u
A=${1:?}; B=${2:?}; OUT=${3:?}; shift 3
TMP=$(mktemp -d /tmp/vrgg14_bnd.XXXXXX)
LIST=$TMP/list
: > "$LIST"
for d in "$@"; do
  [ -d "$d" ] || { echo "MISSING-DIR $d" >> "$OUT.pre"; continue; }
  find "$d" -type f \( -name '*.sv' -o -name '*.v' \) -not -path '*/slpp_all/*' | sort >> "$LIST"
done
LISTED=$(wc -l < "$LIST")
same=0; mov=0; nocomp=0; asym=0; proc=0
{
[ -f "$OUT.pre" ] && cat "$OUT.pre"
# ---- per-FILE arms
while IFS= read -r f <&3; do
  proc=$((proc+1))
  key=$(echo "$f" | tr '/' '_')
  wa=$TMP/a_$key.uhdm; wb=$TMP/b_$key.uhdm
  ( cd "$(dirname "$f")" && "$A" "$(basename "$f")" --single-unit -o "$wa" >/dev/null 2>&1 </dev/null ); ra=$?
  ( cd "$(dirname "$f")" && "$B" "$(basename "$f")" --single-unit -o "$wb" >/dev/null 2>&1 </dev/null ); rb=$?
  if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then
    echo "UNCOMPILABLE $f rc=$ra/$rb"; nocomp=$((nocomp+1))
  elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then
    echo "ASYMMETRY $f rc=$ra/$rb"; asym=$((asym+1))
  elif cmp -s "$wa" "$wb"; then same=$((same+1))
  else echo "MOVER-FILE $f rc=$ra/$rb"; mov=$((mov+1)); fi
  rm -f "$wa" "$wb"
done 3< "$LIST"
echo "-- FILE listed=$LISTED processed=$proc identical=$same MOVERS=$mov uncompilable=$nocomp asymmetries=$asym"
[ "$proc" = "$LISTED" ] || echo "!! PROCESSED != LISTED -- GATE INVALID"
# ---- per-DIRECTORY arms (every dir that holds >1 source: the multi-file arms)
dsame=0; dmov=0; dnoc=0; dasym=0; dproc=0
DIRS=$TMP/dirs
cut -d'/' -f1- "$LIST" | xargs -r -n1 dirname | sort -u > "$DIRS"
DLISTED=$(wc -l < "$DIRS")
while IFS= read -r d <&3; do
  dproc=$((dproc+1))
  key=$(echo "$d" | tr '/' '_')
  wa=$TMP/da_$key.uhdm; wb=$TMP/db_$key.uhdm
  ( cd "$d" && "$A" *.sv *.v --single-unit -o "$wa" >/dev/null 2>&1 </dev/null ); ra=$?
  ( cd "$d" && "$B" *.sv *.v --single-unit -o "$wb" >/dev/null 2>&1 </dev/null ); rb=$?
  if [ ! -f "$wa" ] && [ ! -f "$wb" ]; then
    dnoc=$((dnoc+1))
  elif [ ! -f "$wa" ] || [ ! -f "$wb" ]; then
    echo "DIR-ASYMMETRY $d rc=$ra/$rb"; dasym=$((dasym+1))
  elif cmp -s "$wa" "$wb"; then dsame=$((dsame+1))
  else echo "MOVER-DIR $d rc=$ra/$rb"; dmov=$((dmov+1)); fi
  rm -f "$wa" "$wb"
done 3< "$DIRS"
echo "-- DIR listed=$DLISTED processed=$dproc identical=$dsame MOVERS=$dmov uncompilable=$dnoc asymmetries=$dasym"
[ "$dproc" = "$DLISTED" ] || echo "!! DIR PROCESSED != LISTED -- GATE INVALID"
} > "$OUT" 2>&1
rm -rf "$TMP"; rm -f "$OUT.pre"
tail -6 "$OUT"
