#!/usr/bin/env bash
# r10earl96 -- THE CORPUS CENSUS DRIVER.  MEASUREMENT ONLY; the official
# uhdm-cmp remains the judge.  Runs ct96cen over EVERY database a sweep
# produced, joins each against ITS OWN golden (the cache entry that database's
# own cmds.txt names), scores the two sides as MULTISETS and writes one bucket
# line per database plus every differing cell.  Children get </dev/null; every
# rc is recorded.
#   usage: cen96.sh <sweep-workdir> <out-prefix>
#   env:   CEN96 (the ct96cen binary), SC96 (score96.py)
set -u
CEN=${CEN96:?set CEN96}; SC=${SC96:?set SC96}
W=$(readlink -f "$1"); OUT=$2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.rc"; : > "$OUT.buckets"; : > "$OUT.cells"
T=$(mktemp -d /tmp/r10earl96_cen.XXXXXX)
n=0; miss=0
while IFS= read -r db; do
  d=$(dirname "$db"); tag=${d#$W/}
  gc=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)
  [ -n "$gc" ] && [ -f "$gc/golden.uhdm" ] || { miss=$((miss+1)); echo "NOGOLDEN $tag" >> "$OUT.rc"; continue; }
  "$CEN" "$gc/golden.uhdm" </dev/null 2>/dev/null > "$T/g"; rg=$?
  "$CEN" "$db"             </dev/null 2>/dev/null > "$T/o"; ro=$?
  echo "RC $tag g=$rg o=$ro glines=$(wc -l < "$T/g") olines=$(wc -l < "$T/o")" >> "$OUT.rc"
  if [ $rg -eq 0 ] && [ $ro -eq 0 ]; then
    python3 "$SC" "$T/g" "$T/o" 100000 </dev/null > "$T/s" 2>/dev/null
    echo "$tag $(head -1 "$T/s")" >> "$OUT.buckets"
    tail -n +2 "$T/s" | sed "s#^#$tag\t#" >> "$OUT.cells"
  fi
  n=$((n+1))
done < <(find "$W" -name 'slang.uhdm' | sort)
rm -rf "$T"
echo "-- censused=$n nogolden=$miss"
