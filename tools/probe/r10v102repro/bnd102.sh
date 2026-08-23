#!/bin/bash
# v102 wide boundary: per-FILE and per-DIRECTORY, both views, rc per cell.
# Sources read on fd 3; every child gets </dev/null; scratch keyed on the
# RELATIVE path; PROCESSED asserted against LISTED.
set -u
ROOT=${ROOT:-/tmp/v102_bnd/probe}
OUT=${OUT:-/tmp/v102_bnd/out}
PRIS=${PRIS:-/tmp/v102_bin/pris.bin}
SHIP=${SHIP:-/tmp/v102_bin/ship.bin}
MODE=${1:-file}
rm -rf "$OUT"; mkdir -p "$OUT"
LIST=$OUT/list.txt
cd "$ROOT" || exit 3
if [ "$MODE" = file ]; then
  find . -type f \( -name '*.sv' -o -name '*.v' \) | sort > "$LIST"
else
  find . -type f \( -name '*.sv' -o -name '*.v' \) -printf '%h\n' | sort -u > "$LIST"
fi
LISTED=$(wc -l < "$LIST")
PROCESSED=0; IDENT=0; MOVED=0; NOOUT=0; RCDIFF=0; ASYM=0
exec 3< "$LIST"
while read -r rel <&3; do
  PROCESSED=$((PROCESSED+1))
  key=$(echo "$rel" | sed 's#^\./##; s#[/.]#_#g')
  W=$OUT/c/$key; mkdir -p "$W"
  if [ "$MODE" = file ]; then SRC="$rel"; DIR="."; else
    SRC=$(cd "$ROOT" && ls "$rel"/*.sv "$rel"/*.v 2>/dev/null | sort | tr '\n' ' '); DIR="."
  fi
  [ -n "$SRC" ] || continue
  for view in def elab; do
    if [ "$view" = elab ]; then VF="--elabuhdm"; else VF=""; fi
    ( cd "$ROOT" && "$PRIS" $SRC --single-unit $VF -o "$W/pris.$view.uhdm" > "$W/pris.$view.log" 2>&1 </dev/null ); prc=$?
    ( cd "$ROOT" && "$SHIP" $SRC --single-unit $VF -o "$W/ship.$view.uhdm" > "$W/ship.$view.log" 2>&1 </dev/null ); src=$?
    pe=0; se=0; [ -f "$W/pris.$view.uhdm" ] && pe=1; [ -f "$W/ship.$view.uhdm" ] && se=1
    if [ "$prc" != "$src" ]; then RCDIFF=$((RCDIFF+1)); echo "RC_DIFF $rel $view pris=$prc ship=$src" >> "$OUT/findings.txt"; fi
    if [ "$pe" != "$se" ]; then ASYM=$((ASYM+1)); echo "ASYM $rel $view pris_out=$pe ship_out=$se" >> "$OUT/findings.txt"; fi
    if [ "$pe" = 0 ] && [ "$se" = 0 ]; then NOOUT=$((NOOUT+1)); rm -f "$W"/*.uhdm; continue; fi
    if [ "$pe" = 1 ] && [ "$se" = 1 ]; then
      if cmp -s "$W/pris.$view.uhdm" "$W/ship.$view.uhdm"; then IDENT=$((IDENT+1)); rm -f "$W"/*.$view.uhdm
      else MOVED=$((MOVED+1)); echo "MOVED $rel $view" >> "$OUT/movers.txt"; fi
    fi
  done
  rmdir "$W" 2>/dev/null
done
exec 3<&-
echo "MODE=$MODE LISTED=$LISTED PROCESSED=$PROCESSED"
[ "$LISTED" = "$PROCESSED" ] && echo "PROCESSED_ASSERT OK" || echo "PROCESSED_ASSERT FAIL"
echo "IDENTICAL=$IDENT MOVED=$MOVED NO_OUTPUT=$NOOUT RC_DIFF=$RCDIFF ASYM=$ASYM"
