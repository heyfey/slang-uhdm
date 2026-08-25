#!/usr/bin/env bash
# r10v134 — build the WIDE boundary file list this verifier ran (985 files):
# every probe tree that contains a `foreach`, PLUS the whole of the trees the
# brief names as protected boundaries (r10uvm77-79 / 82-91 / 113 / 122 / 131,
# r10buvm3-15 / 33 / 34, r10sd8-12) whether or not they write one.
#
#   bound134v.sh > list.txt
# then:
#   PRI=<pristine> PAT=<patched> CEN=<ct134cen> FILES=list.txt \
#     ../r10uvm134repro/bound134.sh
#
# The fenced test names are asserted ABSENT from the list (canaudit reads a
# bare mention as a FENCE-BREACH; this script only ever counts them).
set -u
P=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
L=$(mktemp)
for d in $(cd "$P" && ls -d r10*repro); do
  if grep -rlq --include='*.sv' --include='*.svh' 'foreach' "$P/$d" 2>/dev/null; then
    find "$P/$d" \( -name '*.sv' -o -name '*.svh' \) >> "$L"
  fi
done
for n in 77 78 79 82 83 84 85 86 87 88 89 90 91 113 122 131; do
  [ -d "$P/r10uvm${n}repro" ] && find "$P/r10uvm${n}repro" \( -name '*.sv' -o -name '*.svh' \) >> "$L"
done
for n in 3 4 5 6 7 8 9 10 11 12 13 14 15 33 34; do
  [ -d "$P/r10buvm${n}repro" ] && find "$P/r10buvm${n}repro" \( -name '*.sv' -o -name '*.svh' \) >> "$L"
done
for n in 8 9 10 11 12; do
  [ -d "$P/r10sd${n}repro" ] && find "$P/r10sd${n}repro" \( -name '*.sv' -o -name '*.svh' \) >> "$L"
done
sort -u "$L"
n=$(sort -u "$L" | wc -l)
echo "-- $n files" >&2
rm -f "$L"
