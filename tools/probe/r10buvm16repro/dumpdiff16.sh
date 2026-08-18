#!/usr/bin/env bash
# r10buvm16repro/dumpdiff16.sh — ATTRIBUTE every mover, to the LINE.
#
#   usage: dumpdiff16.sh <patched_workdir> <pristine_workdir> <mode/test> ...
#
# Prints, per database, the RAW `uhdm-dump` diff side count and — because the
# campaign's documented `vpiTaskFunc` ORDER COIN makes `default/Scoreboard`
# differ in ~94 sides that are pure reordering — the SORTED-dump side count too.
# The measurement laws require order-blind attribution, so BOTH numbers are
# printed and the sorted one is the claim.
#
# GUARD: a database missing on either side is NAMED and counted, never skipped.
set -u
A=${1:?patched workdir}; B=${2:?pristine workdir}; shift 2
D=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
[ -x "$D" ] || { echo "FATAL: no uhdm-dump at $D"; exit 3; }
miss=0
for t in "$@"; do
  pa=$(ls -d "$A"/$t-*/ 2>/dev/null | head -1); pb=$(ls -d "$B"/$t-*/ 2>/dev/null | head -1)
  if [ -z "$pa" ] || [ -z "$pb" ] || [ ! -f "$pa/slang.uhdm" ] || [ ! -f "$pb/slang.uhdm" ]; then
    echo "MISSING $t"; miss=$((miss+1)); continue
  fi
  "$D" "$pa/slang.uhdm" > /tmp/r10buvm16_dd.a 2>&1
  "$D" "$pb/slang.uhdm" > /tmp/r10buvm16_dd.b 2>&1
  raw=$(diff /tmp/r10buvm16_dd.a /tmp/r10buvm16_dd.b | grep -cE '^[<>]' || true)
  LC_ALL=C sort /tmp/r10buvm16_dd.a > /tmp/r10buvm16_dd.as
  LC_ALL=C sort /tmp/r10buvm16_dd.b > /tmp/r10buvm16_dd.bs
  srt=$(diff /tmp/r10buvm16_dd.as /tmp/r10buvm16_dd.bs | grep -cE '^[<>]' || true)
  echo "== $t  raw_sides=$raw  sorted_sides=$srt"
  diff /tmp/r10buvm16_dd.as /tmp/r10buvm16_dd.bs | grep -E '^[<>]' | sed 's/^/   /' | head -"${DDMAX:-20}"
done
echo "-- MISSING=$miss"
