#!/usr/bin/env bash
# r11u59 CENSUS DRIVER — run cen59 over every row of a sweep workdir, on the
# GOLDEN database and on OURS, writing one stream per side.
# Measurement only; the judge is uhdm-cmp.
#
# The golden database is NOT in the workdir: verify_golden.py serves it from
# ~/.cache/slang-uhdm-goldens and records the cache dir in the row's cmds.txt
# ("surelog: (golden cache hit <dir>)").  On a cache MISS it ran Surelog with
# `-o <work>` and the database is the row's own non-slang *.uhdm.  Both are
# handled; a row with no golden is reported as NOGOLD and is not counted.
#
# usage: cenrun59.sh <workdir> <outprefix>
#   writes <outprefix>.gold.txt, <outprefix>.ours.txt, <outprefix>.rows.txt
set -u
WD=${1:?workdir}
OUT=${2:?outprefix}
CEN=${CEN:-/tmp/r11u59_cen59}
: > $OUT.gold.txt; : > $OUT.ours.txt; : > $OUT.rows.txt
n=0; ng=0; no=0
while IFS= read -r c; do
  d=$(dirname "$c")
  row="$(basename $(dirname "$d"))/$(basename "$d")"     # mode/name-hash
  n=$((n+1))
  g=""
  cd=$(grep -o 'golden cache hit [^)]*' "$c" | head -1 | sed 's/golden cache hit //')
  if [ -n "$cd" ] && [ -f "$cd/golden.uhdm" ]; then
    g="$cd/golden.uhdm"
  else
    g=$(ls "$d"/*.uhdm 2>/dev/null | grep -v '/slang\.uhdm$' | head -1)
  fi
  if [ -n "$g" ] && [ -f "$g" ]; then
    $CEN "$g" "$row" >> $OUT.gold.txt 2>/dev/null && ng=$((ng+1))
  else
    echo "NOGOLD $row" >> $OUT.rows.txt
  fi
  if [ -f "$d/slang.uhdm" ]; then
    $CEN "$d/slang.uhdm" "$row" >> $OUT.ours.txt 2>/dev/null && no=$((no+1))
  else
    echo "NOOURS $row" >> $OUT.rows.txt
  fi
done < <(find "$WD" -name cmds.txt | sort)
echo "CENRUN rows=$n gold_read=$ng ours_read=$no"
