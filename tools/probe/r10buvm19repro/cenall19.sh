#!/usr/bin/env bash
# r10buvm19repro/cenall19.sh — run r10buvm19cen over EVERY database in a sweep
# workdir, both sides.  GOLDEN is taken from the golden CACHE entry the run
# recorded in cmds.txt (a cache hit writes no database into the workdir).
#
# Each job writes its OWN file and the files are concatenated at the end:
# appending to one shared file from N parallel writers interleaves lines
# whenever a write exceeds PIPE_BUF, which silently corrupts the census.
#
# usage: cenall19.sh <workroot> <cen-binary> <out.txt> [jobs]
set -u
W=$1; CEN=$2; OUT=$3; J=${4:-6}
T=$(mktemp -d "${TMPDIR:-/tmp}/cenall19.XXXXXX")
: > "$OUT"
i=0
find "$W" -name cmds.txt | sort | while read -r c; do
  d=$(dirname "$c")
  rel=${d#"$W"/}
  g=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$c")
  [ -n "$g" ] && g="$g/golden.uhdm"
  [ -z "$g" ] && g=$(ls "$d"/slpp_*/*.uhdm 2>/dev/null | head -1)
  i=$((i+1))
  printf '%s|%s|%s|%s/%06d\n' "$rel" "$g" "$d/slang.uhdm" "$T" "$i"
done > "$OUT.jobs"
xargs -a "$OUT.jobs" -P "$J" -I{} bash -c '
  IFS="|" read -r rel g o f <<< "{}"
  { [ -f "$g" ] && '"$CEN"' "$g" "G:$rel"
    [ -f "$o" ] && '"$CEN"' "$o" "O:$rel"; } > "$f"
'
cat "$T"/* >> "$OUT" 2>/dev/null
rm -rf "$T"
echo "rows=$(grep -c '^FA ' "$OUT"; true) summaries=$(grep -c '^SUMMARY ' "$OUT"; true)"
