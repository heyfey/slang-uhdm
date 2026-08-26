#!/usr/bin/env bash
# r10v96 -- THE THREE-SIDED CORPUS CENSUS.  For every database of a sweep, run
# ct96cen on the GOLDEN that database's own cmds.txt names, on the PRISTINE
# database and on the CANDIDATE database, and score them against each other
# with reg96.py, so a cell that was RIGHT on pristine and WRONG on the
# candidate is named.  Children </dev/null; every rc recorded.
# MEASUREMENT ONLY -- the official uhdm-cmp remains the judge.
#   usage: vcen3_96.sh <pristine-workdir> <candidate-workdir> <out-prefix>
#   env:   CEN96 REG96
set -u
CEN=${CEN96:?}; REG=${REG96:?}
WP=$(readlink -f "$1"); WC=$(readlink -f "$2"); OUT=$3
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.rows"; : > "$OUT.worse"; : > "$OUT.rc"
T=$(mktemp -d /tmp/v96_cen3.XXXXXX); n=0; miss=0
while IFS= read -r db; do
  d=$(dirname "$db"); tag=${d#$WP/}
  cdb="$WC/$tag/slang.uhdm"
  [ -f "$cdb" ] || { miss=$((miss+1)); echo "NOCAND $tag" >> "$OUT.rc"; continue; }
  gc=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt" 2>/dev/null)
  [ -n "$gc" ] && [ -f "$gc/golden.uhdm" ] || { miss=$((miss+1)); echo "NOGOLDEN $tag" >> "$OUT.rc"; continue; }
  "$CEN" "$gc/golden.uhdm" </dev/null 2>/dev/null > "$T/g"; rg=$?
  "$CEN" "$db"  </dev/null 2>/dev/null > "$T/p"; rp=$?
  "$CEN" "$cdb" </dev/null 2>/dev/null > "$T/c"; rc=$?
  echo "RC $tag g=$rg p=$rp c=$rc" >> "$OUT.rc"
  [ $rg -eq 0 ] && [ $rp -eq 0 ] && [ $rc -eq 0 ] || continue
  python3 "$REG" "$T/g" "$T/p" "$T/c" </dev/null > "$T/s" 2>/dev/null
  echo "$tag $(tail -1 "$T/s")" >> "$OUT.rows"
  grep '^WORSE' "$T/s" | sed "s#^#$tag\t#" >> "$OUT.worse"
  n=$((n+1))
done < <(find "$WP" -name 'slang.uhdm' | sort)
rm -rf "$T"
echo "-- censused=$n skipped=$miss"
awk '{w+=$3; b+=$5} END {printf "TOTAL RIGHT->WRONG %d  WRONG->RIGHT %d over %d databases\n", w, b, NR}' "$OUT.rows"
