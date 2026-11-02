#!/bin/bash
# awaycensus.sh <pristine> <verified> <out> <casedir>...: byte check of earlier case dirs (single dut.sv),
# absolute paths; prints rc pair and same/MOVED per dir.
A=$1; B=$2; O=$3; shift 3
for c in "$@"; do
  [ -d "$c" ] && [ -f "$c/dut.sv" ] && [ ! -f "$c/FILES" ] || continue
  W=/tmp/v11u466_away$c; mkdir -p $W; rm -f $W/a.uhdm $W/b.uhdm
  (cd $c && timeout 120 "$A" dut.sv --single-unit --nobuiltin -o $W/a.uhdm >/dev/null 2>&1 </dev/null); ra=$?
  (cd $c && timeout 120 "$B" dut.sv --single-unit --nobuiltin -o $W/b.uhdm >/dev/null 2>&1 </dev/null); rb=$?
  m=same; cmp -s $W/a.uhdm $W/b.uhdm || m=MOVED
  echo "$c rc=$ra/$rb $m" >> $O
done
