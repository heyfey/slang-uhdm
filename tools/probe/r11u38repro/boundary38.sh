#!/usr/bin/env bash
# r11u38 THE WIDE BOUNDARY — every committed probe arm in the tree, compiled by
# the NEUTRAL binary (`R11U38_OFF=1`), so the two laws' CLAIMS are printed
# without a byte being written.  An arm this pass would touch is named here
# BEFORE any patched binary runs over it.
#
#   usage: boundary38.sh <binary> <outdir> [probe-root]
#
# GUARDS:
#   * SUBDIRECTORY arms are compiled too (the file list is a full `find`, not a
#     top-level glob), and the list is read on fd 3 with each child's stdin
#     closed, so no child can swallow the list.
#   * PROCESSED is asserted against LISTED and the script exits non-zero if
#     they disagree — a boundary that reaches nothing must never read as green.
#   * each arm's rc is recorded; a compile that FAILS is counted and named, and
#     teaches error recovery, not golden.
#   * the POSITIVE CONTROL is this pass's own grid, compiled by the same
#     driver: it must report claimed cells, or the instrument is blind.
set -u
BIN=${1:?binary}
OUT=${2:?outdir}
ROOT=${3:-$(cd "$(dirname "$0")/.." && pwd)}
[ -x "$BIN" ] || { echo "FATAL: no binary $BIN"; exit 3; }
mkdir -p "$OUT" || exit 3
: > "$OUT/cells.txt"
: > "$OUT/arms.txt"
find "$ROOT" \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) -type f | sort > "$OUT/list.txt"
listed=$(wc -l < "$OUT/list.txt")
processed=0; failed=0
work=$OUT/run
while IFS= read -r f <&3; do
  rm -rf "$work"; mkdir -p "$work"
  ( cd "$(dirname "$f")" && R11U38_OFF=1 R11U38_CELLDBG=1 \
      "$BIN" "$(basename "$f")" --single-unit -o "$work/out.uhdm" ) \
      > "$work/o.log" 2> "$work/e.log" < /dev/null
  rc=$?
  processed=$((processed+1))
  printf '%s rc=%s\n' "$f" "$rc" >> "$OUT/arms.txt"
  [ "$rc" -ne 0 ] && failed=$((failed+1))
  grep '^R11U38 ' "$work/e.log" | sed "s#^#$f #" >> "$OUT/cells.txt"
done 3< "$OUT/list.txt"
rm -rf "$work"
echo "-- LISTED=$listed PROCESSED=$processed compile-failed=$failed"
echo "-- claimed cells: $(grep -c ' R11U38 ' "$OUT/cells.txt"; true)"
echo "-- arms with a claimed cell:"
awk '{print $1}' "$OUT/cells.txt" | sort -u | sed 's/^/     /'
pos=$(grep -c 'r11u38repro/grid/' "$OUT/cells.txt"; true)
echo "-- POSITIVE CONTROL (this pass's own grid arms claim cells): $pos (must be >=1)"
[ "$listed" -eq "$processed" ] || { echo "GATE: PROCESSED != LISTED"; exit 5; }
[ "$pos" -ge 1 ] || { echo "GATE: the boundary driver is BLIND"; exit 5; }
echo "BOUNDARY DRIVER: OK"
