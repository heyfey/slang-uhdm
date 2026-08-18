#!/usr/bin/env bash
# r10buvm17repro/cenours17.sh — census OUR side only, over every database in a
# verify_golden workdir.  Used for the PRISTINE-ONLY mover prediction, which by
# construction must not read a golden or a patched database.
#
#   usage: cenours17.sh <workdir> <outdir> [censusbin]
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; CEN=${3:-/tmp/r10buvm17cen}
[ -x "$CEN" ] || { echo "FATAL: no census binary $CEN"; exit 3; }
mkdir -p "$OUT" || exit 1
n=0; miss=0
for c in "$WD"/*/*/cmds.txt; do
  [ -f "$c" ] || continue
  d=$(dirname "$c"); t=$(basename "$d"); m=$(basename "$(dirname "$d")")
  o="$d/slang.uhdm"
  [ -f "$o" ] || { miss=$((miss+1)); continue; }
  "$CEN" "$o" P > "$OUT/$m.$t.p" 2>/dev/null
  n=$((n+1))
done
echo "censused=$n missing=$miss -> $OUT"
