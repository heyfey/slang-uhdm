#!/usr/bin/env bash
# r10buvm3 — THE sd-FAMILY BOUNDARY, checked the STRONGEST way available.
#
# The standing rules require the committed sd8..sd12 grids to hold byte-identical
# except for cells this pass's law names.  Each of those directories ships its
# OWN scorer (element-kind tables, claim/reach tables, slot tables), and running
# five different scorers proves five different things.  A BYTE comparison of the
# two binaries' databases on every cell is a SUPERSET of all of them: if the
# bytes are equal, every table any scorer could build from them is equal too.
# Where bytes differ the cell is NAMED and its dump delta is printed, so a real
# movement is never summarised away.
#
#   usage: sdbound.sh <pristine-bin> <patched-bin>
#
# GUARDS:
#   * a cell that produces NO database on EITHER binary is reported NO_OUTPUT and
#     counted -- a grid that emitted nothing must never read as "all identical".
#   * the two runs use SEPARATE output directories and the -o path is the ONLY
#     difference in the command line, so the comparison cannot be confounded by
#     the workdir path the emitter embeds (the dump does embed it; the DATABASE
#     bytes here are compared for files written to the same relative name in two
#     dirs, and the SOURCE path handed to both runs is IDENTICAL).
set -u
P=${1:?pristine}; N=${2:?patched}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=/tmp/v83_sdbound; rm -rf "$OUT"; mkdir -p "$OUT/p" "$OUT/n" || exit 9
cells=0; movers=0; noout=0
for d in "$ROOT"/r10sd{8,9,10,11,12}repro; do
  [ -d "$d" ] || continue
  for g in "$d"/grid* "$d"/vgrid* "$d"/qgrid*; do
    [ -d "$g" ] || continue
    for f in "$g"/*.sv; do
      [ -f "$f" ] || continue
      key=$(echo "${f#$ROOT/}" | tr '/' '_')
      cells=$((cells+1))
      "$P" "$f" -o "$OUT/p/$key.uhdm" > "$OUT/p/$key.log" 2>&1
      "$N" "$f" -o "$OUT/n/$key.uhdm" > "$OUT/n/$key.log" 2>&1
      if [ ! -f "$OUT/p/$key.uhdm" ] && [ ! -f "$OUT/n/$key.uhdm" ]; then
        echo "NO_OUTPUT (both) $key"; noout=$((noout+1)); continue
      fi
      if [ ! -f "$OUT/p/$key.uhdm" ] || [ ! -f "$OUT/n/$key.uhdm" ]; then
        echo "MOVER (one side produced no database) $key"; movers=$((movers+1)); continue
      fi
      if ! cmp -s "$OUT/p/$key.uhdm" "$OUT/n/$key.uhdm"; then
        echo "MOVER $key"
        movers=$((movers+1))
        diff -u <("$UHDM_DUMP" "$OUT/p/$key.uhdm" 2>/dev/null | sed 1d) \
                <("$UHDM_DUMP" "$OUT/n/$key.uhdm" 2>/dev/null | sed 1d) \
          | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' | sed 's/^/    /'
      fi
    done
  done
done
echo "-- sd-family cells=$cells MOVERS=$movers NO_OUTPUT(both)=$noout"
# NEGATIVE CONTROL: the comparator must see a single corrupted database.
if [ "${SELFCHECK1:-0}" = 1 ]; then
  v=$(ls "$OUT"/p/*.uhdm | head -1); cp "$v" "$OUT/ctrl.uhdm"
  printf 'X' | dd of="$OUT/ctrl.uhdm" bs=1 seek=0 conv=notrunc status=none
  cmp -s "$v" "$OUT/ctrl.uhdm" && echo "SELFCHECK1_FAILED (comparator blind)" \
                              || echo "SELFCHECK1 OK (one flipped byte is seen)"
fi
