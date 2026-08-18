#!/usr/bin/env bash
# r10uvm91 — the BY-NAME MOVER PREDICTOR, run on PRISTINE bytes ONLY, BEFORE
# the byte verifier is read.  Every database in a pristine sweep workdir is
# scanned with `ct91cen --pred`; a database with >=1 SITE is PREDICTED TO MOVE
# and one with 0 sites is PREDICTED BYTE-IDENTICAL.  The prediction is a SET OF
# NAMES, not a count.
#   usage: pred91.sh <pristine workdir root> <out.txt>
set -u
WD=${1:?pristine workdir}
OUT=${2:?out}
CEN=${CT91CEN:-/tmp/r10uvm91_ct91cen}
[ -x "$CEN" ] || { echo "FATAL: no ct91cen at $CEN"; exit 3; }
: > "$OUT"
n=0; moved=0
while IFS= read -r db; do
  n=$((n+1))
  rel=${db#"$WD"/}; rel=${rel%/slang.uhdm}
  hits=$("$CEN" "$db" --pred 2>/dev/null | grep -c '^SITE ' || true)
  if [ "${hits:-0}" -gt 0 ]; then
    moved=$((moved+1))
    echo "PREDICT-MOVE $rel sites=$hits" >> "$OUT"
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- scanned=$n PREDICT-MOVE=$moved PREDICT-IDENTICAL=$((n-moved))" >> "$OUT"
tail -1 "$OUT"
