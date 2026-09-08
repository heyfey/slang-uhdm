#!/usr/bin/env bash
# r10uvm209 — pred209.sh — MEASUREMENT ONLY.  Walks a PRISTINE verify_golden
# workdir and names, BY TEST AND MODE, every database § 209 will move.  Run
# BEFORE the patched binary exists; the byteverify mover set must EQUAL the set
# printed here.
#
# usage: PRED=<ct209pred> ./pred209.sh <pristine-workdir> <out>
set -u
PRED=${PRED:?ct209pred}; WD=${1:?workdir}; OUT=${2:?out}
: > "$OUT"
visited=0; firing=0
while IFS= read -r db; do
  visited=$((visited+1))
  d=$(dirname "$db")
  # mode/testname-hash, relative to the workdir — never an absolute path, so
  # the artifact carries no scratch location.
  rel=${d#"$WD"/}
  n=$("$PRED" "$db" 2>/dev/null | sed -n 's/^FIRES=//p')
  [ -n "$n" ] || n=NODB
  if [ "$n" != 0 ] && [ "$n" != NODB ]; then
    firing=$((firing+1))
    echo "PRED $rel FIRES=$n" >> "$OUT"
    "$PRED" "$db" 2>/dev/null | grep '^FIRE ' | sed "s#^#PRED $rel #" >> "$OUT"
  fi
done < <(find "$WD" -name slang.uhdm | sort)
echo "-- VISITED=$visited FIRING=$firing" >> "$OUT"
tail -1 "$OUT"
