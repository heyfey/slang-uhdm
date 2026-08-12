#!/usr/bin/env bash
# r10svs7 CELL READER -- prints the golden and ours subtree that begins at the
# FIRST line matching a regex, for `n` lines, from an arm workdir produced by
# ct7arm.sh.  Both dumps already have uhdm-dump's first line (the database path)
# stripped by that driver, so line numbers are comparable within a file but NOT
# across files -- which is why this matches on CONTENT, never on a line number.
#
#   usage: ct7cell.sh <armdir> <regex> [lines]
#
# LHS is ALWAYS golden (g.dump), RHS is ALWAYS ours (o.dump); the banners say so
# on every run so a transposed reading is impossible.
set -u
D=${1:?arm workdir}
RE=${2:?regex}
N=${3:-24}
for side in g o; do
    f="$D/$side.dump"
    [ -s "$f" ] || { echo "MISSING $f"; exit 3; }
    if [ "$side" = g ]; then echo "=== LHS golden(Surelog): $RE ==="
    else echo "=== RHS ours(slang-uhdm): $RE ==="; fi
    ln=$(grep -n -m1 -E "$RE" "$f" | cut -d: -f1)
    if [ -z "$ln" ]; then echo "  (NO MATCH -- the object is ABSENT on this side)"; continue; fi
    sed -n "${ln},$((ln + N - 1))p" "$f"
done
