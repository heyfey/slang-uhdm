#!/usr/bin/env bash
# r10uvm89 — MOVER ATTRIBUTION.  For each byte-mover, the uhdm-dump DELTA of
# the patched vs the pristine database, classified by LINE KIND.  The law
# removes an `|vpiActual:` edge and the object line that follows it, so a clean
# attribution shows ONLY those two kinds; anything else is a line this pass did
# not predict and must be read, not summarised.
#   usage: attr88.sh <patched wd> <pristine wd> <relpath> [relpath...]
set -u
A=${1:?}; B=${2:?}; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
for p in "$@"; do
  "$DUMP" "$A/$p" 2>/dev/null | sed 1d > /tmp/r10uvm89_attr_pat.dump
  "$DUMP" "$B/$p" 2>/dev/null | sed 1d > /tmp/r10uvm89_attr_pris.dump
  n=$(diff /tmp/r10uvm89_attr_pris.dump /tmp/r10uvm89_attr_pat.dump | grep -cE '^[<>]'; true)
  echo "==== $p : $n delta lines"
  diff /tmp/r10uvm89_attr_pris.dump /tmp/r10uvm89_attr_pat.dump | grep -E '^[<>]' |
    sed -E 's/^([<>]) +/\1 /; s/(\\_[a-z_]+):.*/\1/; s/\|(vpi[A-Za-z]+):.*/|\1/' |
    sort | uniq -c | sort -rn
done
