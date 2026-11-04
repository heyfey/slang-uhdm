#!/bin/bash
# bytecensus.sh <binA> <binB> <casedir>...: runs both binaries on each case dir's dut.sv
# (--single-unit --nobuiltin, as runcase.sh) and prints "<dir> rcA rcB SAME|MOVED".  Extra
# environment (switches) passes through.  Explicit case DIRECTORIES only; absolute paths.
A=$1; B=$2; shift 2
[ -x "$A" ] && [ -x "$B" ] || { echo "no binary"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || { echo "skip non-dir $c"; continue; }
  c=$(realpath "$c"); W=/tmp/r11u484_bc$c; mkdir -p "$W"; rm -f "$W/a.uhdm" "$W/b.uhdm"
  (cd "$c" && timeout 300 "$A" dut.sv --single-unit --nobuiltin -o "$W/a.uhdm" > /dev/null 2>&1 </dev/null); ra=$?
  (cd "$c" && timeout 300 "$B" dut.sv --single-unit --nobuiltin -o "$W/b.uhdm" > /dev/null 2>&1 </dev/null); rb=$?
  if cmp -s "$W/a.uhdm" "$W/b.uhdm"; then st=SAME; else st=MOVED; fi
  echo "${c#*/tools/probe/} $ra $rb $st"
done
