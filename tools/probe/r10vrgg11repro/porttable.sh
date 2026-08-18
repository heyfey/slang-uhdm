#!/usr/bin/env bash
# r10vrgg11 — THE PORT-ACTUAL TABLE: the four fields constant::Compare reads
# (VpiDecompile / VpiSize / VpiValue / VpiConstType) for the ELAB port
# High_conn of every cell of a grid, one row per cell, one column per side.
#   usage: porttable.sh <outdir> <cell-name-prefix> <tag> [<tag> ...]
set -u
O=${1:?outdir}; P=${2:-}; shift 2
fields() { awk '/vpiHighConn:/{f=1;c=0;next} f&&c<8{print;c++}' "$1" 2>/dev/null |
           grep -E "vpiDecompile|vpiSize|UINT:|INT:|OCT:|HEX:|BIN:|REAL:|STRING:|vpiConstType" |
           head -4 | tr -d ' \n'; }
for c in $(ls "$O" | sed -n 's/\.gold\.dump$//p' | grep "^$P" | sort); do
  printf "%-40s" "$c"
  printf " gold=%s" "$(fields "$O/$c.gold.dump")"
  for t in "$@"; do printf " %s=%s" "$t" "$(fields "$O/$c.$t.dump")"; done
  echo
done
