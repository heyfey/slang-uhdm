#!/usr/bin/env bash
# r10earl112 -- the WIDE BOUNDARY driver: stage a COPY of tools/probe, build the
# file list at ANY depth, FILTER the slang-fenced test names out of it BEFORE a
# single child runs, then hand it to wide112.sh.
#
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> bash widerun112.sh <probe-src-dir> <out-prefix>
#
# GUARDS:
#   * the fence list is read out of canaudit.sh's own FENCED= line, so the four
#     names are never spelled here and the filter cannot drift from the audit;
#   * FENCED= reports how many listed files the filter removed (0 expected) --
#     a filter that removes nothing and a filter that never ran look different;
#   * LISTED is asserted against wide112.sh's PROCESSED;
#   * rc is recorded per side and split, so an ASYMMETRIC rc is visible.
set -u
SRC=${1:?probe source dir}
OUT=${2:?out prefix}
HERE=$(cd "$(dirname "$0")" && pwd)
STAGE=${STAGE:-/tmp/r10earl112_widest}
COPY=${COPY:-/tmp/r10earl112_probecopy}
rm -rf "$COPY"; mkdir -p "$COPY"
cp -r "$SRC"/. "$COPY"/
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/canaudit.sh")
[ -n "$FENCED" ] || { echo "FATAL: no fence list in canaudit.sh"; exit 3; }
find "$COPY" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$OUT.all"
cp "$OUT.all" "$OUT.txt"
removed=0
for n in $FENCED; do
  before=$(wc -l < "$OUT.txt")
  grep -v "$n" "$OUT.txt" > "$OUT.txt.tmp" || true
  mv "$OUT.txt.tmp" "$OUT.txt"
  after=$(wc -l < "$OUT.txt")
  removed=$((removed + before - after))
done
echo "LISTED=$(wc -l < "$OUT.txt")  FENCED_REMOVED=$removed  (of $(wc -l < "$OUT.all") found)"
PROBE_ROOT="$COPY" STAGE="$STAGE" bash "$HERE/wide112.sh" "$OUT.txt" "$OUT"
cat "$OUT.tally"
awk '{print $2"/"$1}' "$OUT.rc" | sort | uniq -c | awk '{print $2, $1}' | sort > "$OUT.rc_by_side"
echo "-- rc by side --"; cat "$OUT.rc_by_side"
echo "-- differing --"; sort -u "$OUT.diff" | sed "s#^#  #"
p=$(sed -n 's/^PROCESSED=\([0-9]*\).*/\1/p' "$OUT.tally")
l=$(wc -l < "$OUT.txt")
[ "$p" = "$l" ] && echo "PROCESSED==LISTED ($p)" || { echo "PROCESSED-MISMATCH p=$p l=$l"; exit 4; }
