#!/usr/bin/env bash
# r10uvm138 — run pred138 over EVERY database of a verify_golden workdir and
# print the candidate set, BEFORE the patched sweep runs.  The mover set the
# byte audit reports must be a SUBSET of the `enumcands>0` rows here.
#   usage: PRED=<pred138 binary> pred138.sh <workdir> > PREDICT.txt
set -u
WD=${1:?workdir}; PRED=${PRED:?set PRED}
for d in "$WD"/*/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  rel=${d#"$WD"/}; rel=${rel%/}
  "$PRED" "$d/slang.uhdm" "$rel" 2>/dev/null | grep -E '^TOTAL|enum_const$'
done
