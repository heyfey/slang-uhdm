#!/usr/bin/env bash
# r10vbuvm25 wide boundary: every file and every containing directory under a
# copy of tools/probe, in def or elab view. The list rides fd 3, children read
# /dev/null, scratch keys are relative paths, and PROCESSED must equal LISTED.
set -u
ROOT=${1:?probe-copy root}
OUT=${2:?output directory}
MODE=${3:?file or dir}
VIEW=${4:?def or elab}
A=${5:?pristine binary}
B=${6:?patched binary}
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
LIST=$OUT/list.txt
if [ "$MODE" = file ]; then
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | LC_ALL=C sort > "$LIST"
else
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f -printf '%h\n' | LC_ALL=C sort -u > "$LIST"
fi
LISTED=$(wc -l < "$LIST")
PROCESSED=0; IDENT=0; MOVERS=0; UNCOMP=0; ASYM=0
: > "$OUT/movers.txt"; : > "$OUT/uncompilable.txt"; : > "$OUT/rc.txt"
exec 3< "$LIST"
while read -r f <&3; do
  PROCESSED=$((PROCESSED+1))
  rel=${f#$ROOT/}
  key=$(echo "$rel" | tr '/' '_')
  wa=$OUT/w/$key; mkdir -p "$wa"
  if [ "$MODE" = file ]; then SRC=("$f"); else SRC=("$f"/*.sv "$f"/*.v); fi
  EXTRA=(); [ "$VIEW" = elab ] && EXTRA=(--elabuhdm)
  "$A" "${SRC[@]}" --single-unit "${EXTRA[@]}" -o "$wa/a.uhdm" > "$wa/a.log" 2>&1 </dev/null; ra=$?
  "$B" "${SRC[@]}" --single-unit "${EXTRA[@]}" -o "$wa/b.uhdm" > "$wa/b.log" 2>&1 </dev/null; rb=$?
  echo "$rel rc_a=$ra rc_b=$rb" >> "$OUT/rc.txt"
  if [ "$ra" != "$rb" ]; then echo "RC_ASYM $rel $ra $rb" >> "$OUT/movers.txt"; ASYM=$((ASYM+1)); fi
  if [ ! -f "$wa/a.uhdm" ] || [ ! -f "$wa/b.uhdm" ]; then
    if [ -f "$wa/a.uhdm" ] || [ -f "$wa/b.uhdm" ]; then
      echo "DB_ASYM $rel" >> "$OUT/movers.txt"; ASYM=$((ASYM+1))
    else
      echo "$rel rc=$ra" >> "$OUT/uncompilable.txt"; UNCOMP=$((UNCOMP+1))
    fi
    continue
  fi
  "$D" "$wa/a.uhdm" 2>/dev/null | sed '1d' > "$wa/a.dump"
  "$D" "$wa/b.uhdm" 2>/dev/null | sed '1d' > "$wa/b.dump"
  if cmp -s "$wa/a.dump" "$wa/b.dump"; then
    IDENT=$((IDENT+1))
  else
    MOVERS=$((MOVERS+1)); echo "MOVER $rel" >> "$OUT/movers.txt"
  fi
done
exec 3<&-
echo "mode=$MODE view=$VIEW processed=$PROCESSED listed=$LISTED identical=$IDENT movers=$MOVERS uncompilable=$UNCOMP asymmetries=$ASYM"
[ "$PROCESSED" = "$LISTED" ] || { echo "FATAL PROCESSED != LISTED"; exit 7; }
[ "$IDENT" -gt 0 ] || { echo "FATAL zero identical cells"; exit 7; }
