#!/usr/bin/env bash
# r10earl114 -- the WIDE BOUNDARY driver: stage a COPY of tools/probe, build the
# file list at ANY depth, FILTER the slang-fenced test names out of it BEFORE a
# single child runs, then hand it to wide114.sh.
#
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> bash widerun114.sh <probe-src-dir> <out-prefix>
#
# GUARDS:
#   * the fence list is read out of canaudit.sh's own FENCED= line, so the four
#     names are never spelled here and the filter cannot drift from the audit;
#   * FENCED= reports how many listed files the filter removed (0 expected) --
#     a filter that removes nothing and a filter that never ran look different;
#   * LISTED is asserted against wide114.sh's PROCESSED;
#   * rc is recorded per side and split, so an ASYMMETRIC rc is visible.
set -u
SRC=${1:?probe source dir}
OUT=${2:?out prefix}
HERE=$(cd "$(dirname "$0")" && pwd)
STAGE=${STAGE:-/tmp/r10earl114_widest}
COPY=${COPY:-/tmp/r10earl114_probecopy}
rm -rf "$COPY"; mkdir -p "$COPY"
cp -r "$SRC"/. "$COPY"/
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/canaudit.sh")
[ -n "$FENCED" ] || { echo "FATAL: no fence list in canaudit.sh"; exit 3; }
find "$COPY" \( -name '*.sv' -o -name '*.v' \) -type f | sort > "$OUT.all"
# NOTE: the list file is `$OUT.list`, NOT `$OUT.txt`.  A driver invoked as
# `widerun114.sh ... $OUT > $OUT.txt` would otherwise have its stdout redirect
# and its own list file be THE SAME FILE, and the two writers interleave at
# offset 0.  The run itself is still accounted from `$OUT.rc` (4 lines per
# listed file), which is the independent check this collision taught us to make.
cp "$OUT.all" "$OUT.list"
removed=0
for n in $FENCED; do
  before=$(wc -l < "$OUT.list")
  grep -v "$n" "$OUT.list" > "$OUT.list.tmp" || true
  mv "$OUT.list.tmp" "$OUT.list"
  after=$(wc -l < "$OUT.list")
  removed=$((removed + before - after))
done
echo "LISTED=$(wc -l < "$OUT.list")  FENCED_REMOVED=$removed  (of $(wc -l < "$OUT.all") found)"
PROBE_ROOT="$COPY" STAGE="$STAGE" bash "$HERE/wide114.sh" "$OUT.list" "$OUT"
cat "$OUT.tally"
awk '{print $2"/"$1}' "$OUT.rc" | sort | uniq -c | awk '{print $2, $1}' | sort > "$OUT.rc_by_side"
echo "-- rc by side --"; cat "$OUT.rc_by_side"
echo "-- differing --"; sort -u "$OUT.diff" | sed "s#^#  #"
p=$(sed -n 's/^PROCESSED=\([0-9]*\).*/\1/p' "$OUT.tally")
l=$(wc -l < "$OUT.list")
[ "$p" = "$l" ] && echo "PROCESSED==LISTED ($p)" || { echo "PROCESSED-MISMATCH p=$p l=$l"; exit 4; }
