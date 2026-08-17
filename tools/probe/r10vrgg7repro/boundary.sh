#!/usr/bin/env bash
# r10vrgg7/boundary.sh — compile EVERY source arm of the named precedent repro
# directories with N binaries and compare each against the FIRST one byte-wise.
#
#   usage: boundary.sh <out> <ref-bin> <bin2> <label2> [<bin3> <label3> ...] -- <dir>...
#
# GUARDS (each an ops trap this campaign has paid for):
#   * SUBDIRECTORY arms are compiled too (`find`, not a top-level glob).
#   * THE FILE LIST IS READ ON FD 3 and every child gets `</dev/null`, so a
#     compiler that reads stdin cannot swallow the list and shorten the run.
#   * PROCESSED is asserted against the list length: if the loop processed
#     fewer files than `find` listed, the run is FATAL, not "0 movers".
#   * a file NO binary compiles is UNCOMPILABLE and COUNTED; a file only SOME
#     compile is an ASYMMETRY and reported loudly.  A driver that reaches
#     nothing must never read as agreement.
set -u
OUT=${1:?outfile}; REF=${2:?ref bin}; shift 2
pairs=()
while [ $# -gt 0 ] && [ "$1" != "--" ]; do pairs+=("$1"); shift; done
[ "${1:-}" = "--" ] && shift
LIST=$(mktemp /tmp/vrgg7_bndlist.XXXXXX)
for d in "$@"; do
  if [ -d "$d" ]; then
    find "$d" -type f \( -name '*.sv' -o -name '*.v' \) | sort >> "$LIST"
  else
    echo "MISSING-DIR $d"
  fi
done
WANT=$(wc -l < "$LIST")
n=0; nocomp=0
declare -A SAME MOVED ASYM
{
echo "== list=$WANT files, ref=$REF"
while IFS= read -r f <&3; do
  n=$((n+1))
  wr=$(mktemp -u /tmp/vrgg7_bnd_ref.XXXXXX.uhdm)
  (cd "$(dirname "$f")" && "$REF" "$(basename "$f")" --single-unit -o "$wr" \
      >/dev/null 2>&1 </dev/null)
  k=0
  anyref=0; [ -f "$wr" ] && anyref=1
  allmissing=1; [ "$anyref" = 1 ] && allmissing=0
  while [ $k -lt ${#pairs[@]} ]; do
    bin=${pairs[$k]}; lbl=${pairs[$((k+1))]}
    wx=$(mktemp -u /tmp/vrgg7_bnd_x.XXXXXX.uhdm)
    (cd "$(dirname "$f")" && "$bin" "$(basename "$f")" --single-unit -o "$wx" \
        >/dev/null 2>&1 </dev/null)
    if [ -f "$wx" ]; then allmissing=0; fi
    if [ "$anyref" = 1 ] && [ -f "$wx" ]; then
      if cmp -s "$wr" "$wx"; then SAME[$lbl]=$(( ${SAME[$lbl]:-0} + 1 ))
      else echo "MOVER[$lbl] $f"; MOVED[$lbl]=$(( ${MOVED[$lbl]:-0} + 1 )); fi
    elif [ "$anyref" != 1 ] && [ ! -f "$wx" ]; then
      : # both sides absent -> accounted below as UNCOMPILABLE
    else
      echo "ASYMMETRY[$lbl] $f (ref=$anyref this=$([ -f "$wx" ] && echo 1 || echo 0))"
      ASYM[$lbl]=$(( ${ASYM[$lbl]:-0} + 1 ))
    fi
    rm -f "$wx"
    k=$((k+2))
  done
  [ "$allmissing" = 1 ] && { echo "UNCOMPILABLE $f"; nocomp=$((nocomp+1)); }
  rm -f "$wr"
done 3< "$LIST"
echo "-- PROCESSED=$n WANT=$WANT uncompilable=$nocomp"
k=0
while [ $k -lt ${#pairs[@]} ]; do
  lbl=${pairs[$((k+1))]}
  echo "-- [$lbl] identical=${SAME[$lbl]:-0} MOVERS=${MOVED[$lbl]:-0} asymmetries=${ASYM[$lbl]:-0}"
  k=$((k+2))
done
if [ "$n" != "$WANT" ]; then
  echo "FATAL: PROCESSED($n) != WANT($WANT) -- the list was truncated, this run proves NOTHING"
fi
} > "$OUT" 2>&1
rm -f "$LIST"
grep -E '^(--|FATAL|MOVER|ASYM|UNCOMP|==)' "$OUT" | head -60
