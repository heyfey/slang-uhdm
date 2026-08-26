#!/usr/bin/env bash
# r10uvm153 — THE A-PRIORI PREDICTION.  Runs ct153pred over EVERY `slang.uhdm`
# in a PRISTINE verify_golden workdir and names, database by database, the cells
# § classPropRefBindsPkgListing153 will move.  It reads OUR databases only —
# golden is never consulted — so the mover set is named before the patched sweep
# exists.  MEASUREMENT ONLY.
#   usage: PRED=<ct153pred> predsweep153.sh <workdir> <out.txt>
set -u
WD=${1:?workdir}; OUT=${2:?out}
PRED=${PRED:?set PRED}
: > "$OUT"
n=0; hit=0
while read -r f <&3; do
  n=$((n+1))
  r=$("$PRED" "$f" --quiet 2>/dev/null | tail -1)
  c=$(sed 's/.*predicted-cells=\([0-9]*\).*/\1/' <<<"$r")
  [ -z "$c" ] && c=0
  if [ "$c" != "0" ]; then
    hit=$((hit+1))
    echo "== $f cells=$c" >> "$OUT"
    "$PRED" "$f" 2>/dev/null | sed 's/^/   /' >> "$OUT"
  fi
done 3< <(find "$WD" -name slang.uhdm | sort)
echo "-- scanned=$n databases-with-predicted-cells=$hit" | tee -a "$OUT"
