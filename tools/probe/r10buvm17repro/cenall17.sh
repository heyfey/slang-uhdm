#!/usr/bin/env bash
# r10buvm17repro/cenall17.sh — run the foreach census over EVERY database in a
# verify_golden workdir, on BOTH sides, into <out>/<mode>.<test>.{g,p}.
#
#   usage: cenall17.sh <workdir> <outdir> [censusbin]
#
# GUARDS: the golden path is read out of each dir's own cmds.txt (the cache
# entry, turned into .../golden.uhdm), so this cannot silently census the wrong
# golden; a missing side is reported, never skipped silently.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; CEN=${3:-/tmp/r10buvm17cen}
[ -x "$CEN" ] || { echo "FATAL: no census binary $CEN"; exit 3; }
mkdir -p "$OUT" || exit 1
n=0; miss=0
for c in "$WD"/*/*/cmds.txt; do
  [ -f "$c" ] || continue
  d=$(dirname "$c"); t=$(basename "$d"); m=$(basename "$(dirname "$d")")
  g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$c")/golden.uhdm
  o="$d/slang.uhdm"
  if [ ! -f "$g" ] || [ ! -f "$o" ]; then echo "MISS $m/$t g=$g o=$o"; miss=$((miss+1)); continue; fi
  "$CEN" "$g" G > "$OUT/$m.$t.g" 2>/dev/null
  "$CEN" "$o" P > "$OUT/$m.$t.p" 2>/dev/null
  n=$((n+1))
done
echo "censused=$n missing=$miss -> $OUT"
