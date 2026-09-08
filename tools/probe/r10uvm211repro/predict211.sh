#!/usr/bin/env bash
# r10uvm211repro/predict211.sh — the A-PRIORI mover prediction over a COMPLETED
# PRISTINE sweep workdir.  MEASUREMENT ONLY.  Run BEFORE the patched sweep is
# read; the output file IS the prediction of record.
#
#   PRED=<ct211pred> predict211.sh <pristine workdir> <out.txt>
#
# Every `<mode>/<test>-<hash>/slang.uhdm` under the workdir is scanned; a row
# that produced NO database is REPORTED (`NODB`), never silently skipped.
#
# THE FENCE.  The four slang-fenced tests are never dispatched by this driver
# and their names are never SPELLED in it or in its output: the list is read at
# run time out of `canaudit.sh`'s own `FENCED=` line — the one file in this
# directory the audit lets name them — and a row whose name is on it is skipped
# and counted as FENCED.
set -u
WD=${1:?workdir}; OUT=${2:?out}
PRED=${PRED:?set PRED to the built ct211pred}
HERE=$(cd "$(dirname "$0")" && pwd)
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/canaudit.sh")
[ -n "$FENCED" ] || { echo "FATAL: could not read the fence list from canaudit.sh"; exit 3; }
: > "$OUT"
fenced=0
n=0; nodb=0
for mode in default testflags folded; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    b=$(basename "$d")
    t="${b%-*}"
    row="$t,$mode"
    skip=0
    for fn in $FENCED; do [ "$t" = "$fn" ] && skip=1; done
    if [ "$skip" = 1 ]; then echo "FENCED $mode" >> "$OUT"; fenced=$((fenced+1)); continue; fi
    if [ -f "$d/slang.uhdm" ]; then
      "$PRED" "$d/slang.uhdm" "$row" >> "$OUT" 2>&1
      n=$((n+1))
    else
      echo "NODB $row" >> "$OUT"; nodb=$((nodb+1))
    fi
  done
done
echo "-- scanned=$n NODB=$nodb FENCED=$fenced" >> "$OUT"
echo "scanned=$n NODB=$nodb FENCED=$fenced"
echo "REFUSED-SHARED POPULATION (shared>0 — the element refs § 207 refused):"
grep '^PREDCELLS ' "$OUT" | awk '$3!="shared=0"' | sort
echo "PREDICTED MOVERS — ROWS WITH A NON-EMPTY SPLIT SET (the declarations that get a fresh chain):"
grep '^PREDCELLS ' "$OUT" | awk '$4!="splits=0"' | sort
