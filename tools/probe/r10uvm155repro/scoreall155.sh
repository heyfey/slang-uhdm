#!/bin/bash
# r10uvm155 — SCORE EVERY GRID ARM IN BOTH DIRECTIONS.  MEASUREMENT ONLY.
# For each arm: the cells golden and the PRISTINE binary disagree on, the cells
# golden and the PATCHED binary disagree on, and — the two numbers that decide
# the pass — MOVED-TOWARD (a cell wrong before and right after) and
# MOVED-WRONG/AWAY (a cell right before and wrong after, or wrong before and
# DIFFERENTLY wrong after).
#
#   usage: scoreall155.sh <griddir-prefix> [arm ...]
# where <griddir-prefix><arm>/cen.g.txt / cen.a.txt (pristine) / cen.b.txt
# (patched) are what grid155.sh wrote.
set -u
P=${1:?griddir prefix}; shift
D=$(dirname "$(readlink -f "$0")")
tot_t=0; tot_w=0
for a in "$@"; do
  W=$P$a
  [ -f "$W/cen.g.txt" ] || { echo "MISSING $W/cen.g.txt"; exit 3; }
  python3 "$D/score155.py" "$W/cen.g.txt" "$W/cen.a.txt" | grep -E '^(DIFF|ONLY)' \
    | awk '{print $2, $3}' | sort > "$W/diff.pris.txt"
  python3 "$D/score155.py" "$W/cen.g.txt" "$W/cen.b.txt" | grep -E '^(DIFF|ONLY)' \
    | awk '{print $2, $3}' | sort > "$W/diff.pat.txt"
  t=$(comm -23 "$W/diff.pris.txt" "$W/diff.pat.txt" | grep -c . ; true)
  w=$(comm -13 "$W/diff.pris.txt" "$W/diff.pat.txt" | grep -c . ; true)
  printf "%-10s pristine-DIFF=%-4s patched-DIFF=%-4s MOVED-TOWARD=%-4s MOVED-WRONG/AWAY=%s\n" \
    "$a" "$(grep -c . "$W/diff.pris.txt"; true)" "$(grep -c . "$W/diff.pat.txt"; true)" "$t" "$w"
  [ "$w" -gt 0 ] && { echo "   NEW DIFFS:"; comm -13 "$W/diff.pris.txt" "$W/diff.pat.txt" | sed 's/^/     /'; }
  tot_t=$((tot_t+t)); tot_w=$((tot_w+w))
done
echo "-- TOTAL MOVED-TOWARD=$tot_t  MOVED-WRONG/AWAY=$tot_w"
