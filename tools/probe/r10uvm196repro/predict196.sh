#!/usr/bin/env bash
# r10uvm196 — THE MOVER PREDICTOR.  MEASUREMENT ONLY.
#
# Runs ct196cen's OURS-ONLY `--pred` mode over every database a PRISTINE sweep
# produced, so the mover set is named BEFORE any patched binary exists and
# without needing a golden (a row whose golden is missing still gets a verdict).
#
# usage: CEN=<path to ct196cen> ./predict196.sh <pristine workdir> <out file> [jobs]
set -u
CEN=${CEN:?set CEN to the ct196cen binary}
WD=${1:?workdir}
OUT=${2:?out file}
J=${3:-2}
: > "$OUT"
find "$WD" -name slang.uhdm | sort > "$OUT.list"
N=$(wc -l < "$OUT.list")
echo "-- databases listed: $N" >> "$OUT"
run_one() {
  db=$1
  # the row tag is <mode>/<test-dir>, taken from the path RELATIVE to the
  # workdir root so two rows of the same test never collide
  tag=$(printf '%s' "$db" | sed "s|^$WD/||; s|/slang.uhdm$||")
  timeout 900 "$CEN" --pred "$db" "$tag" 2>&1
  echo "RC $tag $?"
}
export -f run_one
export CEN WD
xargs -a "$OUT.list" -P "$J" -I{} bash -c 'run_one "$@"' _ {} >> "$OUT" 2>&1
P=$(grep -c 'PREDICTED-MOVER' "$OUT" || true)
R=$(grep -c '^RC ' "$OUT" || true)
F=$(grep -c 'PRED-RESTORE_FAIL' "$OUT" || true)
NZ=$(awk '$1=="RC" && $3!=0' "$OUT" | wc -l)
echo "-- PROCESSED=$R LISTED=$N PREDICTED_MOVERS=$P RESTORE_FAILS=$F NONZERO_RC=$NZ" >> "$OUT"
tail -1 "$OUT"
