#!/usr/bin/env bash
# r10uvm147 — run pred147 over EVERY ours-side database of a PRISTINE
# verify_golden workdir and print the candidate set BY NAME.  MEASUREMENT-ONLY.
#   usage: [PRED=..] pred147.sh <workdir> <label>
set -u
WD=${1:?workdir}; LBL=${2:-set}
PRED=${PRED:-/tmp/r10uvm147_pred147}
tot=0; hit=0
for m in default testflags; do
  for d in "$WD/$m"/*/; do
    [ -d "$d" ] || continue
    O=$d/slang.uhdm; [ -f "$O" ] || continue
    tot=$((tot+1))
    n=$(basename "$d")
    c=$("$PRED" "$O" 2>/dev/null | tail -1 | awk '{print $2}')
    [ -z "$c" ] && c=0
    if [ "$c" != "0" ]; then echo "CAND $m/$n count=$c"; hit=$((hit+1)); fi
  done
done
echo "-- $LBL databases=$tot candidates=$hit"
