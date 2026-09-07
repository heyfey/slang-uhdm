#!/usr/bin/env bash
# r10uvm202repro/predict202.sh — the A-PRIORI mover prediction over a COMPLETED
# PRISTINE sweep workdir.  MEASUREMENT ONLY.  Run BEFORE the patched sweep is
# read; the output file IS the prediction of record.
#
#   PRED=<ct202pred> predict202.sh <pristine workdir> <out.txt>
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
PRED=${PRED:?set PRED to the built ct202pred}
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
echo "PREDICTED MOVERS (strict>0):"
grep '^PREDCELLS ' "$OUT" | awk '$3!="strict=0"' | sort
echo "ROWS WITH A NON-EMPTY WIDE BOUND (the superset the movers must stay inside):"
grep '^PREDCELLS ' "$OUT" | awk '$4!="wide=0"' | sort
