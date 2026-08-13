#!/usr/bin/env bash
# r10uvm68 — THE COUNTEREXAMPLE HUNT for § atomVarSignedWritten68.
#
#   usage: ct68ctrex.sh <g1.dump> [<g2.dump> ...]
#
# The law says a GOLDEN variable whose typespec is NAMED never carries
# `vpiSigned`.  One counterexample refutes it.  This script looks for one in
# every dump it is given and prints the NAMED-object population beside the
# hit count, because "0 counterexamples out of 0 objects" is vacuous and must
# not read like "0 out of 242".
#
# INPUTS MUST BE GOLDEN dumps (LHS).  Run on OURS and every row is a mover, not
# a counterexample -- the caller states which side it passed.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
[ $# -gt 0 ] || { echo "REFUSING TO REPORT: no dumps given"; exit 4; }
tot=0; hits=0
printf '%-30s %-10s %s\n' DUMP NAMEDOBJS COUNTEREXAMPLES
for f in "$@"; do
  [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
  t=$(python3 "$HERE/ct68census.py" "$f" |
        awk '$2 ~ /^NAMED:/ {n+=$4} END{print n+0}')
  h=$(python3 "$HERE/ct68census.py" "$f" |
        awk '$2 ~ /^NAMED:/ && $3=="signed=1" {n+=$4} END{print n+0}')
  tot=$((tot+t)); hits=$((hits+h))
  printf '%-30s %-10s %s\n' "$(basename "$f")" "$t" "$h"
done
echo "---- NAMED-typespec variable OBJECTS examined: $tot   COUNTEREXAMPLES: $hits"
[ "$tot" -gt 0 ] || { echo "REFUSING TO REPORT: examined 0 objects"; exit 4; }
[ "$hits" -eq 0 ] && echo "LAW HOLDS on every dump given" \
                  || { echo "LAW REFUTED -- read the rows above"; exit 1; }
