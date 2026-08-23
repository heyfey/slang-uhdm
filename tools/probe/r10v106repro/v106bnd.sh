#!/usr/bin/env bash
# v106bnd.sh — wide boundary from a COPY of tools/probe, NO path filter,
# .sv AND .v, recursive, BOTH views, per-FILE and per-DIRECTORY halves.
# File list read on fd 3; children get </dev/null; PROCESSED asserted;
# scratch keyed on the RELATIVE path; rc recorded per cell.
set -u
PRI=${PRI:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; WD=${BWD:?}; MODE=${BMODE:-file}
VIEW=${BVIEW:-def}
[ "$VIEW" = elab ] && FLAG="--elabuhdm" || FLAG=""
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/list.txt
if [ "$MODE" = file ]; then
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$LIST"
else
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f -printf '%h\n' | sort -u > "$LIST"
fi
listed=$(wc -l < "$LIST"); [ "$listed" -gt 0 ] || { echo EMPTY-LIST; exit 4; }
n=0
exec 3< "$LIST"
while IFS= read -r item <&3; do
  n=$((n+1))
  rel=${item#$ROOT/}
  printf '%06d\t%s\n' "$n" "$rel" >> "$WD/work.txt"
done
exec 3<&-
export PRI PAT WD ROOT MODE FLAG
cat "$WD/work.txt" | xargs -P "${JOBS:-4}" -I{} -d '\n' bash -c '
  IFS=$(printf "\t"); set -- $0; idx=$1; rel=$2; unset IFS
  item=$ROOT/$rel
  o=$WD/$idx; mkdir -p "$o"
  if [ "$MODE" = file ]; then
    cp "$item" "$o/" 2>/dev/null || exit 0; args=$(basename "$item")
  else
    args=""
    for f in "$item"/*.sv "$item"/*.v; do [ -f "$f" ] || continue; cp "$f" "$o/" 2>/dev/null; args="$args $(basename "$f")"; done
    [ -n "$args" ] || exit 0
  fi
  ( cd "$o" && $PRI $args --single-unit $FLAG -o pris.uhdm >pris.log 2>&1 </dev/null ); pr=$?
  ( cd "$o" && $PAT $args --single-unit $FLAG -o ship.uhdm >ship.log 2>&1 </dev/null ); sr=$?
  ph=NONE; sh=NONE
  [ -f "$o/pris.uhdm" ] && ph=$(md5sum "$o/pris.uhdm" | cut -d" " -f1)
  [ -f "$o/ship.uhdm" ] && sh=$(md5sum "$o/ship.uhdm" | cut -d" " -f1)
  echo -e "CELL\t$rel\tpris_rc=$pr\tship_rc=$sr\t$ph\t$sh" >> "$WD/cells.tsv"
' {} 
proc=$(grep -c '^CELL' "$WD/cells.tsv" 2>/dev/null || echo 0)
moved=$(awk -F'\t' '$5!=$6' "$WD/cells.tsv" | wc -l)
rcdiff=$(awk -F'\t' '$3!=$4' "$WD/cells.tsv" | wc -l)
noout=$(awk -F'\t' '$5=="NONE"||$6=="NONE"' "$WD/cells.tsv" | wc -l)
asym=$(awk -F'\t' '($5=="NONE")!=($6=="NONE")' "$WD/cells.tsv" | wc -l)
echo "BOUNDARY mode=$MODE view=$VIEW LISTED=$listed PROCESSED=$proc MOVED=$moved RC_DIFF=$rcdiff NOOUT=$noout ASYM=$asym"
awk -F'\t' '$5!=$6 {print "  MOVER "$2}' "$WD/cells.tsv" | sort
