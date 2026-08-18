#!/usr/bin/env bash
# r10rgg13repro/dumpdiff13.sh — THE ARBITER of "what did the patch change in one
# design": a WHOLE-DUMP, PATH-NORMALISED diff of the same test's database built
# by the two binaries.  A cmp line count is the head OBJECT's decompile size and
# is never a progress metric; this is.
#
#   usage: dumpdiff13.sh <base.uhdm> <pat.uhdm> <outfile>
#
# The dump embeds the WORKDIR path, so both sides are normalised before the diff
# (RESUME §9: "Dump paths embed the workdir — normalise before cross-dir diffs").
set -u
A=${1:?base db}; B=${2:?pat db}; OUT=${3:?outfile}
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
[ -f "$A" ] && [ -f "$B" ] || { echo "FATAL: missing input"; exit 3; }
ta=$(mktemp); tb=$(mktemp)
"$D" "$A" 2>/dev/null | sed -E 's#/tmp/[A-Za-z0-9_.]+/#<WD>/#g' > "$ta"
"$D" "$B" 2>/dev/null | sed -E 's#/tmp/[A-Za-z0-9_.]+/#<WD>/#g' > "$tb"
{
  echo "-- base dump lines=$(wc -l < "$ta")  pat dump lines=$(wc -l < "$tb")"
  diff "$ta" "$tb"
  echo "-- removed=$(diff "$ta" "$tb" | grep -c '^<'; true) added=$(diff "$ta" "$tb" | grep -c '^>'; true)"
} > "$OUT" 2>&1
tail -1 "$OUT"
rm -f "$ta" "$tb"
