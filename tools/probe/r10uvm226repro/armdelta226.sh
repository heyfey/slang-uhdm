#!/bin/bash
# r10uvm226 — THE THREE-WAY SCORE, on TWO axes.
#
#   CELL  axis: the whole process subtree, keyed holder#view[index] — the way
#               interface_inst::Compare reads the Process() vector.
#   FIELD axis: every LINE of the flattened subtree, keyed by cell + ordinal —
#               the axis a whole-cell compare is BLIND to (r10v225 §2.1: a
#               single judge-visible field can go right -> wrong inside a cell
#               that is wrong on both binaries and the cell score never moves).
#
# Verdicts, per key:  TO-GOLDEN  pristine wrong, patched right
#                     AWAY       pristine right, patched wrong   <-- must be 0
#                     STILL-WRONG both wrong
#                     SAME-RIGHT  both right
#
#   usage: bash armdelta226.sh <pristine-griddir> <patched-griddir> [armname]
set -u
D=$(cd "$(dirname "$0")" && pwd)
P=${1:?pristine griddir}
Q=${2:?patched griddir}
ONLY=${3:-}
for a in "$P"/*/; do
    n=$(basename "$a")
    [ -n "$ONLY" ] && [ "$n" != "$ONLY" ] && continue
    [ -f "$P/$n/golden.dump" ] || continue
    [ -f "$P/$n/ours.dump" ]   || continue
    [ -f "$Q/$n/ours.dump" ]   || continue
    python3 "$D/proccen226.py" "$P/$n/golden.dump" | sort > "$P/$n/g.proc"
    python3 "$D/proccen226.py" "$P/$n/ours.dump"   | sort > "$P/$n/o.proc"
    python3 "$D/proccen226.py" "$Q/$n/ours.dump"   | sort > "$Q/$n/o.proc"
    python3 "$D/tri226.py" "$P/$n/g.proc" "$P/$n/o.proc" "$Q/$n/o.proc" "$n"
done | tee /dev/stderr | awk '
    /^CELLSUM/  {ct+=$2; ca+=$3; cs+=$4; cr+=$5}
    /^FIELDSUM/ {ft+=$2; fa+=$3; fs+=$4; fr+=$5}
    END{printf "ARMDELTA  CELL  TO-GOLDEN %d  AWAY %d  STILL-WRONG %d  SAME-RIGHT %d\n", ct,ca,cs,cr;
        printf "ARMDELTA  FIELD TO-GOLDEN %d  AWAY %d  STILL-WRONG %d  SAME-RIGHT %d\n", ft,fa,fs,fr}' \
    2>/dev/null
