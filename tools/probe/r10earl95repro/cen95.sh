#!/usr/bin/env bash
# r10earl95 -- THE CORPUS CENSUS.  MEASUREMENT ONLY; the official uhdm-cmp
# remains the judge.  Runs ct94cen over EVERY database a sweep produced, joins
# each against ITS OWN golden (the cache entry the test's own cmds.txt names),
# and writes one line per (database, key, payload) cell plus a per-database
# bucket line.  Every child gets </dev/null and its rc is RECORDED.
#   usage: cen94.sh <sweep-workdir> <out-prefix>
#   env:   CEN95 (the ct94cen binary)
set -u
CEN=${CEN95:?set CEN95}
W=$(readlink -f "$1"); OUT=$2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.rc"; : > "$OUT.g"; : > "$OUT.o"
n=0; miss=0
while IFS= read -r db; do
  d=$(dirname "$db"); tag=${d#$W/}
  gc=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)
  [ -n "$gc" ] && [ -f "$gc/golden.uhdm" ] || { miss=$((miss+1)); echo "NOGOLDEN $tag" >> "$OUT.rc"; continue; }
  "$CEN" "$gc/golden.uhdm" 2>/dev/null </dev/null | sed "s#^#$tag\t#" >> "$OUT.g"; rg=${PIPESTATUS[0]}
  "$CEN" "$db"             2>/dev/null </dev/null | sed "s#^#$tag\t#" >> "$OUT.o"; ro=${PIPESTATUS[0]}
  echo "RC $tag g=$rg o=$ro" >> "$OUT.rc"
  n=$((n+1))
done < <(find "$W" -name 'slang.uhdm' | sort)
echo "-- censused=$n nogolden=$miss"
