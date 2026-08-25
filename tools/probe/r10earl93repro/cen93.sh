#!/usr/bin/env bash
# r10earl93 -- MEASUREMENT ONLY.  Run the CS/PA/CV census over EVERY database a
# sweep produced, joining each against ITS OWN golden (the cache entry the
# test's own cmds.txt names), and emit per-(database,family,bucket) counts plus
# the MOVED-WRONG cells.  The official uhdm-cmp remains the judge.
#   usage: cen93.sh <sweep-workdir> <out-prefix>
#   env:   CEN93 (ct93cen binary)
# Every child gets </dev/null and its rc is recorded.
set -u
CEN=${CEN93:?set CEN93}
W=$(readlink -f "$1"); OUT=$2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.counts"; : > "$OUT.cells"; : > "$OUT.rc"
TMP=$(mktemp -d /tmp/r10earl93_cenwk.XXXXXX)
n=0; miss=0
while IFS= read -r db; do
  d=$(dirname "$db"); tag=${d#$W/}
  gc=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)
  [ -n "$gc" ] && [ -f "$gc/golden.uhdm" ] || { miss=$((miss+1)); echo "NOGOLDEN $tag" >> "$OUT.rc"; continue; }
  "$CEN" "$gc/golden.uhdm" --inst > "$TMP/g.rows" 2>/dev/null </dev/null; rg=$?
  "$CEN" "$db"             --inst > "$TMP/o.rows" 2>/dev/null </dev/null; ro=$?
  echo "RC $tag g=$rg o=$ro" >> "$OUT.rc"
  [ $rg -eq 0 ] && [ $ro -eq 0 ] || continue
  python3 "$(dirname "$0")/score93.py" "$TMP/g.rows" "$TMP/o.rows" "$tag" \
      --cells "$OUT.cells" >> "$OUT.counts"
  n=$((n+1))
done < <(find "$W" -name '*.uhdm' | sort)
rm -rf "$TMP"
echo "-- scored=$n nogolden=$miss"
