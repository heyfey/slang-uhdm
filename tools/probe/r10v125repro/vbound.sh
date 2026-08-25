#!/usr/bin/env bash
# v125 verifier WIDE BOUNDARY: every committed probe arm, both binaries, both
# views, compared BYTE for BYTE.  fd-3 file list, children </dev/null, scratch
# keyed on the RELATIVE path, rc recorded per cell, NO path filter.
set -u
PRIS=${PRIS:?}; PAT=${PAT:?}; ROOT=${ROOT:?}; OUT=${OUT:?}
mkdir -p "$OUT"; : > "$OUT/cells.txt"
rel="$1"
f="$ROOT/$rel"
d="$OUT/scr/$(echo "$rel" | tr '/' '_')"
mkdir -p "$d"; cp "$f" "$d/" 2>/dev/null || { echo "CELL $rel NOCOPY"; exit 0; }
b=$(basename "$f"); lang=
for view in def elab; do
  fl=""; [ "$view" = elab ] && fl="--elabuhdm"
  ( cd "$d" && "$PRIS" "$b" $lang $fl -o p_$view.uhdm > p_$view.log 2>&1 </dev/null ); rp=$?
  ( cd "$d" && "$PAT"  "$b" $lang $fl -o q_$view.uhdm > q_$view.log 2>&1 </dev/null ); rq=$?
  if [ -f "$d/p_$view.uhdm" ] && [ -f "$d/q_$view.uhdm" ]; then
    if cmp -s "$d/p_$view.uhdm" "$d/q_$view.uhdm"; then st=SAME; else st=BYTES_DIFFER; fi
  else st=NO_DB; fi
  echo "CELL	$rel	$view	$st	rcp=$rp	rcq=$rq"
done
rm -rf "$d"
