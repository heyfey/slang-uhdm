#!/usr/bin/env bash
# r10uvm82 — THE FULL sd / uvm / buvm ARM-AND-GRID BOUNDARY, by BYTES.
#
# The standing rules require the committed sd/uvm/buvm grids to hold identical
# except for cells this pass's law names.  `r10buvm3repro/sdbound.sh` covers the
# r10sd8..12 grid DIRECTORIES; this one covers EVERY `.sv` arm and grid cell in
# EVERY `tools/probe/r10{sd,uvm,buvm}*repro` directory, which is a superset of
# every per-pass scorer: equal bytes => every table any scorer could build from
# them is equal.
#
#   usage: allbound82.sh <pristine-bin> <patched-bin>
#
# GUARDS:
#   * a cell that produces NO database on EITHER binary is NO_OUTPUT and COUNTED
#     — a boundary run that emitted nothing must never read as "all identical".
#   * the two runs differ ONLY in the -o path; the SOURCE path handed to both is
#     byte-identical, so the emitter's embedded workdir cannot confound it.
#   * the cell count is printed and a count of 0 is exit 4 (a vacuous run).
set -u
P=${1:?pristine binary}; N=${2:?patched binary}
for b in "$P" "$N"; do [ -x "$b" ] || { echo "FATAL: not executable: $b"; exit 3; }; done
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=/tmp/r10uvm82_allbound; rm -rf "$OUT"; mkdir -p "$OUT/p" "$OUT/n" || exit 9
cells=0; movers=0; noout=0
for d in "$ROOT"/r10sd*repro "$ROOT"/r10uvm*repro "$ROOT"/r10buvm*repro; do
  [ -d "$d" ] || continue
  while IFS= read -r f; do
    key=$(echo "${f#$ROOT/}" | tr '/' '_')
    cells=$((cells+1))
    "$P" "$f" --nobuiltin -o "$OUT/p/$key.uhdm" >/dev/null 2>&1
    "$N" "$f" --nobuiltin -o "$OUT/n/$key.uhdm" >/dev/null 2>&1
    if [ ! -s "$OUT/p/$key.uhdm" ] && [ ! -s "$OUT/n/$key.uhdm" ]; then
      noout=$((noout+1)); continue
    fi
    if ! cmp -s "$OUT/p/$key.uhdm" "$OUT/n/$key.uhdm"; then
      echo "MOVER $key"
      movers=$((movers+1))
    fi
  done < <(find "$d" -maxdepth 2 -name '*.sv' | sort)
done
echo "CELLS=$cells MOVERS=$movers NO_OUTPUT=$noout"
[ "$cells" -gt 0 ] || { echo VACUOUS; exit 4; }
