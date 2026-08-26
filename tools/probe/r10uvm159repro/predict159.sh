#!/bin/bash
# r10uvm159 — PREDICT THE MOVER SET BY NAME, from PRISTINE databases only.
# MEASUREMENT ONLY.  Run BEFORE the patched sweep exists: the law can only move
# a database that holds at least one cell of its population, so the pristine
# census names the movers.
#   usage: predict159.sh <pristine-cls-census.txt> [<pristine-cls-census.txt> ...]
set -u
SEL='own=operation ctx=tf home=cls'
for f in "$@"; do
  grep "TALLY MISSING-OURS $SEL" "$f" 2>/dev/null | awk '{print $1, $NF}'
done | sort -u
echo "-- every database NOT listed above must be BYTE-IDENTICAL after the patch"
