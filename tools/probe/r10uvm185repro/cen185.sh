#!/usr/bin/env bash
# r10uvm185 — run `ct185cen` over a set of sweep rows, golden AND ours, and
# write one TSV pair per row-mode.  MEASUREMENT ONLY.
#
#   usage: CEN=<ct185cen binary> ./cen185.sh <sweep-workdir> <outdir> <name>...
#
# The golden database for each row is read out of that row's OWN `cmds.txt`
# (`surelog: (golden cache hit <dir>)`), never guessed from a name — SeqDriver's
# default and testflags goldens are DIFFERENT cache entries (RESUME.md §9).
# A row whose golden or ours is missing is reported SKIP-NOFILE and counted.
set -u
CEN=${CEN:?set CEN to the ct185cen binary}
WD=${1:?sweep workdir}
OUT=${2:?output dir}
shift 2
NAMES=${*:?at least one test name}
mkdir -p "$OUT"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$HOME/.local/lib64:$HOME/.local/lib
ok=0; skip=0
for mode in default testflags; do
  for n in $NAMES; do
    d=$(find "$WD/$mode" -maxdepth 1 -type d -name "$n-*" 2>/dev/null | head -1)
    if [ -z "$d" ]; then echo "SKIP-NODIR $n $mode"; skip=$((skip+1)); continue; fi
    g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$d/cmds.txt")/golden.uhdm
    o="$d/slang.uhdm"
    if [ ! -f "$g" ] || [ ! -f "$o" ]; then
      echo "SKIP-NOFILE $n $mode g=$g"; skip=$((skip+1)); continue
    fi
    "$CEN" "$g" > "$OUT/$n.$mode.g.tsv"
    "$CEN" "$o" > "$OUT/$n.$mode.o.tsv"
    echo "OK $n $mode g=$(grep -c . "$OUT/$n.$mode.g.tsv") o=$(grep -c . "$OUT/$n.$mode.o.tsv")"
    ok=$((ok+1))
  done
done
echo "-- census rows: OK=$ok SKIP=$skip"
