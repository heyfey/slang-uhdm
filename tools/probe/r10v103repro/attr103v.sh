#!/usr/bin/env bash
# r10v103repro/attr103v.sh — ORDER-BLIND attribution of one byte mover.
# Dumps both databases, normalises the embedded workdir path and every `id:NNN`,
# SORTS both (so a pure ORDERING coin — Scoreboard/default's vpiTaskFunc flip —
# contributes nothing) and prints the changed lines with the SOURCE LINES they
# carry.  Add STRIP_INDENT=1 to also strip leading blanks, which turns a pure
# RE-PARENTING (an object that only moved a level in the tree) into no change.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   [WDROOT=<sweep root>] [STRIP_INDENT=1] attr103v.sh <patched db> <pristine db> <out prefix>
#
# WDROOT is the sweep root whose absolute path the dumps embed; both sides must
# normalise to the same text or every line reads as a mover.
set -u
A=${1:?patched db}; B=${2:?pristine db}; OUT=${3:?out prefix}
WDROOT=${WDROOT:-}
STRIP_INDENT=${STRIP_INDENT:-0}
norm() {
  uhdm-dump "$1" 2>&1 </dev/null \
    | { if [ -n "$WDROOT" ]; then sed "s#${WDROOT}/##g"; else cat; fi; } \
    | sed -E 's#, id:[0-9]+##g; s#^[^:]*\.uhdm: ##' \
    | { if [ "$STRIP_INDENT" = 1 ]; then sed -E 's/^ +//'; else cat; fi; } \
    | LC_ALL=C sort
}
norm "$A" > "$OUT.pat"; norm "$B" > "$OUT.pris"
echo "sorted-identical: $(cmp -s "$OUT.pat" "$OUT.pris" && echo YES || echo NO)"
diff "$OUT.pris" "$OUT.pat" > "$OUT.diff" || true
echo "changed lines: $(grep -cE '^[<>]' "$OUT.diff"; true)"
echo "-- source lines carried by the changed lines:"
grep -E '^[<>]' "$OUT.diff" | grep -oE 'line:[0-9]+:' | cut -d: -f2 | sort -n | uniq -c | sort -rn | head -40
echo "-- object kinds on the changed lines:"
grep -E '^[<>]' "$OUT.diff" | grep -oE '^[<>] *\\_[a-z_]+' | sed -E 's/ +/ /' | sort | uniq -c | sort -rn | head -20
