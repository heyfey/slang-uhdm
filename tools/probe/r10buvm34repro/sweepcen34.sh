#!/usr/bin/env bash
# r10buvm34repro/sweepcen34.sh — run the FOREACH LOOP-VARIABLE census over a whole
# verify_golden workdir, on BOTH sides (golden cache + our slang.uhdm), in both
# modes.  MEASUREMENT ONLY.
#
#   sweepcen34.sh <workdir> <cen-binary> <out.tsv>
#
# Every row is tagged `<side>|<test>|<mode>` so the join is symmetric and the
# DEF/ELAB view never enters a key (RESUME §9: the two producers label it
# differently).  A missing side is COUNTED, never skipped silently (uhdm-cmp's
# "exits 0 on a missing file" trap, same shape).
set -u
WD=${1:?workdir}; CEN=${2:?census binary}; OUT=${3:?out.tsv}
: > "$OUT"; miss=0; did=0
for mode in default testflags; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d"); n=${n%-*}
    O="$d/slang.uhdm"; C="$d/cmds.txt"; G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "MISS	$n	$mode	g=${G:-none}	o=$O" >> "$OUT.miss"; miss=$((miss+1)); continue
    fi
    "$CEN" "$G" "G|$n|$mode" >> "$OUT" 2>>"$OUT.err"
    "$CEN" "$O" "O|$n|$mode" >> "$OUT" 2>>"$OUT.err"
    did=$((did+1))
  done
done
echo "CENSUSED $did  MISSING-SIDE $miss  -> $OUT"
