#!/usr/bin/env bash
# r10vrgg16 WIDE BOUNDARY — per-FILE and per-DIRECTORY arms over a COPY of the
# WHOLE tools/probe tree, NO path filter, .sv AND .v, in BOTH views
# (default and --elabuhdm).
#
# GUARDS, each an ops trap this campaign has paid for:
#   * subdirectory arms are found with `find`, never a top-level glob;
#   * the file list is read on fd 3 and every child gets </dev/null, so a child
#     cannot swallow the list;
#   * PROCESSED is asserted against LISTED;
#   * rc is recorded PER CELL (a rc=139 segfault is not a "reject");
#   * a file NEITHER binary compiles is UNCOMPILABLE and COUNTED;
#   * a file only ONE binary compiles is an ASYMMETRY, reported loudly;
#   * the dump's first line (the output-path banner) is dropped, because the two
#     arms write different output names;
#   * the four slang-FENCED test names are never dispatched.
#   usage: vboundary16.sh <probe-copy-root> <outdir> <file|dir> <view>
set -u
ROOT=${1:?probe copy root}; OUT=${2:?out}; MODE=${3:-file}; VIEW=${4:-def}
A=/tmp/vrgg16_bin/base; B=/tmp/vrgg16_bin/patched
EL=""; [ "$VIEW" = elab ] && EL="--elabuhdm"
DMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
LIST=$OUT/list.txt
FENCE='UnsignedParam|HierPathEval|FileLocalParam|TopParam'
if [ "$MODE" = file ]; then
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f | grep -vE "$FENCE" | LC_ALL=C sort > "$LIST"
else
  find "$ROOT" \( -name '*.sv' -o -name '*.v' \) -type f -printf '%h\n' | grep -vE "$FENCE" | LC_ALL=C sort -u > "$LIST"
fi
LISTED=$(wc -l < "$LIST")
echo "MODE=$MODE VIEW=$VIEW LISTED=$LISTED"
PROCESSED=0; IDENT=0; MOVERS=0; UNCOMP=0; ASYM=0
: > "$OUT/movers.txt"; : > "$OUT/uncompilable.txt"; : > "$OUT/rc.txt"
exec 3< "$LIST"
while read -r f <&3; do
  PROCESSED=$((PROCESSED+1))
  rel=${f#$ROOT/}
  key=$(echo "$rel" | tr '/' '_')
  wa=$OUT/w/$key; mkdir -p "$wa"
  if [ "$MODE" = file ]; then SRC=("$f"); else SRC=("$f"/*.sv "$f"/*.v); fi
  "$A" "${SRC[@]}" --single-unit $EL -o "$wa/a.uhdm" > "$wa/a.log" 2>&1 </dev/null; ra=$?
  "$B" "${SRC[@]}" --single-unit $EL -o "$wa/b.uhdm" > "$wa/b.log" 2>&1 </dev/null; rb=$?
  echo "$rel rc_a=$ra rc_b=$rb" >> "$OUT/rc.txt"
  [ "$ra" = "$rb" ] || { echo "RC_ASYM $rel $ra $rb" >> "$OUT/movers.txt"; ASYM=$((ASYM+1)); }
  if [ ! -f "$wa/a.uhdm" ] && [ ! -f "$wa/b.uhdm" ]; then
    echo "$rel rc=$ra/$rb" >> "$OUT/uncompilable.txt"; UNCOMP=$((UNCOMP+1))
    rm -rf "$wa"; continue
  fi
  if [ ! -f "$wa/a.uhdm" ] || [ ! -f "$wa/b.uhdm" ]; then
    echo "DB_ASYM $rel" >> "$OUT/movers.txt"; ASYM=$((ASYM+1)); rm -rf "$wa"; continue
  fi
  if cmp -s "$wa/a.uhdm" "$wa/b.uhdm"; then
    IDENT=$((IDENT+1)); rm -rf "$wa"
  else
    echo "MOVER $rel" >> "$OUT/movers.txt"; MOVERS=$((MOVERS+1))
    $DMP "$wa/a.uhdm" 2>/dev/null | tail -n +2 > "$wa/a.dump"
    $DMP "$wa/b.uhdm" 2>/dev/null | tail -n +2 > "$wa/b.dump"
    if cmp -s "$wa/a.dump" "$wa/b.dump"; then
      echo "   (dump identical: banner-only)" >> "$OUT/movers.txt"
    else
      diff "$wa/a.dump" "$wa/b.dump" > "$wa/diff.txt"
      echo "   dumpdiff -$(grep -c '^<' "$wa/diff.txt"; true)/+$(grep -c '^>' "$wa/diff.txt"; true)" >> "$OUT/movers.txt"
    fi
  fi
done
exec 3<&-
echo "LISTED=$LISTED PROCESSED=$PROCESSED IDENT=$IDENT MOVERS=$MOVERS UNCOMPILABLE=$UNCOMP ASYM=$ASYM"
[ "$LISTED" = "$PROCESSED" ] || { echo "FATAL: PROCESSED != LISTED"; exit 4; }
[ "$PROCESSED" -gt 0 ] || { echo "FATAL: processed nothing"; exit 5; }
