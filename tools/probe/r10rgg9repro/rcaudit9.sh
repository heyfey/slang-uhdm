#!/usr/bin/env bash
# r10rgg9/rcaudit9.sh — RECORD THE EXIT CODE of every arm cell, both binaries.
#
#   usage: rcaudit9.sh <base-bin> <pat-bin> <outfile>
#
# The standing ops rule is that EVERY arm cell must record rc and no cell may
# exit 139: `verify_golden.py` files an rc=139 SEGFAULT as SLANG_REJECT wearing
# the last stderr warning, so a crash on legal SV can hide inside a green
# histogram (r10rgg8's shipped predicate segfaulted on three cells that way).
# This driver reads the rc directly and histograms it.
set -u
A=${1:?base bin}; B=${2:?pat bin}; OUT=${3:?outfile}
ROOT=$(cd "$(dirname "$0")" && pwd)
{
n=0; seg=0
for d in "$ROOT"/cells/*/; do
  c=$(basename "$d")
  n=$((n+1))
  (cd "$d" && "$A" dut.sv --single-unit -o /tmp/r10rgg9_rc_a.uhdm >/dev/null 2>&1)
  ra=$?
  (cd "$d" && "$B" dut.sv --single-unit -o /tmp/r10rgg9_rc_b.uhdm >/dev/null 2>&1)
  rb=$?
  printf '%-18s base_rc=%-4s pat_rc=%-4s\n' "$c" "$ra" "$rb"
  [ "$ra" = 139 ] && seg=$((seg+1))
  [ "$rb" = 139 ] && seg=$((seg+1))
done
rm -f /tmp/r10rgg9_rc_a.uhdm /tmp/r10rgg9_rc_b.uhdm
echo "-- cells=$n SEGFAULTS(rc=139)=$seg"
} > "$OUT" 2>&1
