#!/usr/bin/env bash
# r10uvm180 — run predict180 over every database of a PRISTINE sweep workdir
# and print the predicted mover set BY NAME.  Reads OUR databases only; no
# golden and no patched artifact is opened, so the prediction cannot be
# back-fitted to the result it is checked against.
#
# usage: predict180.sh <predict180-binary> <pristine-workdir> <out-file>
#        e.g. predict180.sh /tmp/pred180 /tmp/wd_pris/sl /tmp/PREDICT.sl.txt
set -u
BIN=${1:?predict180 binary}
WD=${2:?pristine sweep workdir}
OUT=${3:?output file}
: > "$OUT"
n=0
find "$WD" -name slang.uhdm -print0 | sort -z | while IFS= read -r -d '' db; do
    rel=${db#"$WD"/}
    res=$("$BIN" "$db" 2>&1 | head -1)
    case "$res" in
        "PREDICT MOVER"*) printf 'MOVER %s %s\n' "$res" "$rel" >> "$OUT" ;;
        "PREDICT SAME")   : ;;
        *)                printf 'PROBLEM %s %s\n' "$res" "$rel" >> "$OUT" ;;
    esac
    n=$((n+1))
done
echo "SCANNED $(find "$WD" -name slang.uhdm | wc -l) databases under $WD"
echo "PREDICTED MOVERS $(grep -c '^MOVER' "$OUT" 2>/dev/null || echo 0)"
echo "PROBLEMS $(grep -c '^PROBLEM' "$OUT" 2>/dev/null || echo 0)"
