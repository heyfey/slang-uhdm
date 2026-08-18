#!/usr/bin/env bash
# r10vbuvm21repro/vbound21.sh — THE WIDE BOUNDARY GATE.  Every `.sv` / `.v`
# under a COPY of tools/probe (subdirectories by construction, NO path filter),
# compiled by BOTH binaries in BOTH views, dumps normalised, rc per cell,
# PROCESSED asserted against LISTED, rejects counted per binary.
#
# usage: vbound21.sh <binA> <binB> <probe-copy-root> <outdir> [view: def|elab]
set -u
A=$1; B=$2; ROOT=$3; OUT=$4; VIEW=${5:-def}
SLE=""; [ "$VIEW" = elab ] && SLE="--elabuhdm"
mkdir -p "$OUT"
LIST="$OUT/list.txt"
( cd "$ROOT" && find . -name '*.sv' -o -name '*.v' | sort ) > "$LIST"
LISTED=$(grep -c '^' "$LIST"; true)
P=0; DIFFER=0; RA=0; RB=0
: > "$OUT/differ.txt"; : > "$OUT/rc.txt"
while read -r f <&3; do
  P=$((P+1))
  key=$(echo "$f" | sed 's#^\./##; s#/#__#g')
  d="$OUT/cells/$key"; mkdir -p "$d"
  ( cd "$ROOT/$(dirname "$f")" && "$A" "$(basename "$f")" $SLE -o "$d/a.uhdm" > "$d/a.log" 2>&1 ) </dev/null
  ra=$?
  ( cd "$ROOT/$(dirname "$f")" && "$B" "$(basename "$f")" $SLE -o "$d/b.uhdm" > "$d/b.log" 2>&1 ) </dev/null
  rb=$?
  echo "$f rcA=$ra rcB=$rb" >> "$OUT/rc.txt"
  [ $ra -ne 0 ] && RA=$((RA+1))
  [ $rb -ne 0 ] && RB=$((RB+1))
  if [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ]; then
    uhdm-dump "$d/a.uhdm" 2>&1 | sed -e "1s#^[^:]*\.uhdm:#<DB>:#" -e "s#$d#<D>#g" > "$d/a.txt"
    uhdm-dump "$d/b.uhdm" 2>&1 | sed -e "1s#^[^:]*\.uhdm:#<DB>:#" -e "s#$d#<D>#g" > "$d/b.txt"
    if ! cmp -s "$d/a.txt" "$d/b.txt"; then DIFFER=$((DIFFER+1)); echo "$f" >> "$OUT/differ.txt"; fi
    rm -f "$d/a.uhdm" "$d/b.uhdm"
  fi
done 3< "$LIST"
echo "VIEW=$VIEW LISTED=$LISTED PROCESSED=$P REJECTS_A=$RA REJECTS_B=$RB DIFFER=$DIFFER"
[ "$LISTED" = "$P" ] && echo "PROCESSED_OK" || echo "PROCESSED_MISMATCH"
