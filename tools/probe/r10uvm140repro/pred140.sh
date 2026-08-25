#!/usr/bin/env bash
# r10uvm140 — run pred140 over EVERY database of a verify_golden workdir and
# print the candidate set, BEFORE the patched sweep runs.  The byte-mover set
# must be a SUBSET of the databases named here.
#   usage: PRED=<pred140 binary> pred140.sh <workdir>
set -u
WD=${1:?workdir}; PRED=${PRED:?set PRED}
for d in "$WD"/*/*/; do
  [ -f "$d/slang.uhdm" ] || continue
  rel=${d#"$WD"/}; rel=${rel%/}
  "$PRED" "$d/slang.uhdm" "$rel" 2>/dev/null | grep -E '^TOTAL|^CAND|^EMPTY'
done
