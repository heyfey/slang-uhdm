#!/usr/bin/env bash
# r10uvm72repro/ct72cells.sh — the per-CELL table for an arm workdir: every
# named call, with the FULL NAME OF WHAT IT BINDS, one line per print.
#
# LHS is ALWAYS golden.  Prints golden, the side under test, and a `diff` of
# the two, so a cell that matches golden is visible as an ABSENT diff line
# rather than as an eyeballed pair.
#
#   usage: ct72cells.sh <armwd> <callee> [<callee> ...]
set -u
WD=${1:?arm workdir}; shift
HERE=$(cd "$(dirname "$0")" && pwd)
[ -s "$WD/g.dump" ] || { echo "FATAL: no $WD/g.dump"; exit 3; }
[ -s "$WD/o.dump" ] || { echo "FATAL: no $WD/o.dump"; exit 3; }
for n in "$@"; do
  for side in g o; do
    python3 "$HERE/ct72sites.py" "$WD/$side.dump" "$n" --chain --only all \
      | grep -v '^TOTAL' | awk '{$1=""; print}' | sed 's/  */ /g' | sort
  done > /dev/null
  python3 "$HERE/ct72sites.py" "$WD/g.dump" "$n" --chain --only all \
    | grep -v '^TOTAL' | awk '{$1=""; print}' | sed 's/  */ /g' | sort > "$WD/.g.$n"
  python3 "$HERE/ct72sites.py" "$WD/o.dump" "$n" --chain --only all \
    | grep -v '^TOTAL' | awk '{$1=""; print}' | sed 's/  */ /g' | sort > "$WD/.o.$n"
  echo "---- callee '$n': golden prints=$(wc -l < "$WD/.g.$n") ours=$(wc -l < "$WD/.o.$n")"
  if diff "$WD/.g.$n" "$WD/.o.$n" > "$WD/.d.$n"; then
    echo "     CELLS IDENTICAL TO GOLDEN"
  else
    echo "     DIFFERING CELLS (< golden, > ours):"
    sed 's/^/       /' "$WD/.d.$n"
  fi
done
