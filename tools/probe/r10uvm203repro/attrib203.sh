#!/usr/bin/env bash
# r10uvm203repro/attrib203.sh — THE ATTRIBUTION of every byte mover.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
# THE ORDER-BLIND SORTED DUMP DIFF.  RESUME §9: `Scoreboard/default` is a
# ~50/50 COIN per invocation, so a raw dump diff reads as change even when
# nothing moved.  Both databases are dumped, the workdir path (which the dump
# embeds) is normalised away, both are SORTED, and the two are diffed — a pure
# ORDER flip then scores zero lines.
#
# § oobCtorLocalsRideTheImport203 is ADDITIVE except in two named places, so
# both counters carry meaning:
#   ADDED    — the materialized-import entries the law adds, plus the class
#              name their class_typespecs gain;
#   REMOVED  — bounded and EXPECTED: the implicit netType-1 wire the
#              `$dumpvars` scope-name arm no longer mints when a real net of
#              that name exists (SimpleUVM's `top`), and nothing else.
# Every removed line is printed in full so the claim can be read, not summarised.
#
#   usage: attrib203.sh <patched workdir> <pristine workdir> <outdir> <rel...>
set -u
PW=${1:?patched workdir}; RW=${2:?pristine workdir}; OUT=${3:?outdir}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT" || exit 3
tot=0; rem_tot=0
for rel in "$@"; do
  p="$PW/$rel"; r="$RW/$rel"
  key=$(echo "$rel" | tr '/' '_')
  if [ ! -f "$p" ] || [ ! -f "$r" ]; then echo "MISSING $rel"; continue; fi
  "$DUMP" "$p" 2>/dev/null | sed "s|$PW||g" | sort > "$OUT/$key.pat"
  "$DUMP" "$r" 2>/dev/null | sed "s|$RW||g" | sort > "$OUT/$key.pri"
  comm -13 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.added"
  comm -23 "$OUT/$key.pri" "$OUT/$key.pat" > "$OUT/$key.removed"
  add=$(wc -l < "$OUT/$key.added"); rem=$(wc -l < "$OUT/$key.removed")
  echo "== $rel  ADDED=$add REMOVED=$rem"
  if [ "$rem" -gt 0 ]; then echo "---- REMOVED lines:"; cat "$OUT/$key.removed"; fi
  tot=$((tot+add)); rem_tot=$((rem_tot+rem))
done
echo "-- TOTAL ADDED=$tot REMOVED=$rem_tot"
