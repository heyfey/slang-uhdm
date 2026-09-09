#!/bin/bash
# r10uvm227 — run the a-priori predictor over EVERY database of a PRISTINE
# verify_golden workdir.  MEASUREMENT ONLY; reads pristine databases only.
#
#   usage: bash predict227.sh <pristine-workdir> <out.txt>
#
# Every database is LISTED first and PROCESSED is asserted against it, so a
# glob that reaches nothing can never read as "no candidates".
set -u
WD=${1:?pristine workdir}
OUT=${2:?out}
PRED=${PRED:-/tmp/r10uvm227_ct227pred}
[ -x "$PRED" ] || { echo "FATAL: no ct227pred at $PRED"; exit 3; }
: > "$OUT"
listed=0
tmp=$(mktemp /tmp/r10uvm227_predlist.XXXXXX)
find "$WD" -name slang.uhdm -print > "$tmp"
listed=$(grep -c . "$tmp"; true)
processed=0
while read -r db <&3; do
    d=$(dirname "$db")
    tag=$(basename "$(dirname "$d")")/$(basename "$d")
    "$PRED" "$tag" "$db" >> "$OUT" 2>&1
    processed=$((processed+1))
done 3< "$tmp"
rm -f "$tmp"
echo "predict227: LISTED $listed PROCESSED $processed"
[ "$listed" = "$processed" ] && echo "predict227: LISTED == PROCESSED" \
                             || echo "  !! LISTED != PROCESSED"
echo "predict227: CANDIDATES $(grep -c ' CANDIDATE ' "$OUT"; true) / $processed"
grep ' CANDIDATE ' "$OUT" | sort
