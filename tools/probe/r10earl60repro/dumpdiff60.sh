#!/usr/bin/env bash
# r10earl60 — the whole-dump PATH-NORMALISED diff between two of our own dumps
# (pristine vs patched), plus the ADDED/REMOVED line histogram that makes the
# blast radius readable.
#
# Traps encoded:
#   * dump paths EMBED THE WORKDIR, so every absolute path is reduced to its
#     BASENAME before the diff or the whole file reads as changed.
#   * uhdm-dump's first line is the database path; earl60.sh already sed'd it.
#   * the histogram strips leading whitespace, because raw indentation makes
#     TREE DEPTH part of the key and turns a cell that landed ON golden into a
#     phantom mover (r10earl59's varm59 instrument bug).
set -u
A=${1:?dump A (pristine)}
B=${2:?dump B (patched)}
O=${3:?out prefix}
for f in "$A" "$B"; do [ -s "$f" ] || { echo "FATAL: missing/empty $f"; exit 9; }; done
norm() { sed -E 's#/[A-Za-z0-9_./+-]*/([A-Za-z0-9_.+-]+\.(sv|svh|vh|v))#\1#g' "$1"; }
norm "$A" > "$O.a"; norm "$B" > "$O.b"
if diff -u "$O.a" "$O.b" > "$O.diff"; then echo "DUMP_IDENTICAL"; exit 0; fi
echo "diff lines=$(grep -cE '^[-+]' "$O.diff") hunks=$(grep -c '^@@' "$O.diff")"
echo "--- ADDED (top 25, whitespace-stripped) ---"
grep '^+' "$O.diff" | grep -v '^+++' | sed 's/^+[[:space:]]*//' | sort | uniq -c | sort -rn | head -25
echo "--- REMOVED (top 25, whitespace-stripped) ---"
grep '^-' "$O.diff" | grep -v '^---' | sed 's/^-[[:space:]]*//' | sort | uniq -c | sort -rn | head -25
echo "ADDED_TOTAL=$(grep -c '^+' "$O.diff")  REMOVED_TOTAL=$(grep -c '^-' "$O.diff")  (incl. the 1 +++/--- header each)"
