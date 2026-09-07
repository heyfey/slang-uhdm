#!/usr/bin/env bash
# r10uvm189repro/predict189.sh — the A-PRIORI mover prediction over a whole
# sweep workdir, from the PRISTINE databases alone.  MEASUREMENT ONLY.
#   CT189=<ct189assoc> predict189.sh <PRISTINE workdir> <out.txt>
# Prints LISTED / PROCESSED / NOGOLDEN / PREDICTED and one line per predicted
# database with its cells.  Every database is asserted PROCESSED so a silent
# skip cannot read as "nothing predicted" (RESUME §9's boundary rule).
set -u
WD=$1; OUT=$2
CEN=${CT189:?set CT189 to the built ct189assoc}
: > "$OUT"
LISTED=0; PROCESSED=0; NODB=0; PRED=0
while IFS= read -r db; do
  LISTED=$((LISTED+1))
  if [ ! -s "$db" ]; then NODB=$((NODB+1)); echo "NODB $db" >> "$OUT"; continue; fi
  out=$("$CEN" pred "$db" 2>/dev/null </dev/null)
  rc=$?
  PROCESSED=$((PROCESSED+1))
  n=$(printf '%s\n' "$out" | sed -n 's/^PREDICT cells=\([0-9]*\).*/\1/p')
  [ -z "$n" ] && n=0
  if [ "$n" != 0 ]; then
    PRED=$((PRED+1))
    echo "PREDICTED $db cells=$n rc=$rc" >> "$OUT"
    printf '%s\n' "$out" | grep '^CELL ' | sed 's/^/    /' >> "$OUT"
  fi
done 3< /dev/null < <(find "$WD" -name 'slang.uhdm' | sort)
echo "LISTED=$LISTED PROCESSED=$PROCESSED NOGOLDEN=$NODB PREDICTED=$PRED" | tee -a "$OUT"
[ "$LISTED" = "$((PROCESSED+NODB))" ] && echo "PROCESSED-ASSERT-OK" | tee -a "$OUT" \
  || { echo "PROCESSED-ASSERT-FAIL" | tee -a "$OUT"; exit 1; }
