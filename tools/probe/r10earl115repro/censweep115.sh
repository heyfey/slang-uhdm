#!/usr/bin/env bash
# r10earl115 CORPUS SWEEP -- MEASUREMENT ONLY.  Runs an instrument over every
# database of a verify_golden workdir (both modes), OURS and/or GOLDEN, with an
# ACCOUNTING PASS: LISTED / PROCESSED / SKIPPED / FAIL are all printed, so a
# sweep that reached nothing cannot read as "no rows differ".
#   censweep115.sh <workdir> <out-prefix> <tool> <side:ours|gold|both>
set -u
WD=${1:?workdir}; OUT=${2:?outprefix}; TOOL=${3:?tool}; SIDE=${4:-both}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
listed=0; proc=0; skip=0; fail=0
: > "$OUT.ours.txt"; : > "$OUT.gold.txt"
for mode in default testflags; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    listed=$((listed+1))
    n=$(basename "$d")
    O="$d/slang.uhdm"; C="$d/cmds.txt"; G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
    if [ ! -f "$O" ]; then skip=$((skip+1)); continue; fi
    if [ "$SIDE" = ours ] || [ "$SIDE" = both ]; then
      "$TOOL" "$O" "$mode/$n" >> "$OUT.ours.txt" 2>&1 || fail=$((fail+1))
    fi
    if [ "$SIDE" = gold ] || [ "$SIDE" = both ]; then
      if [ -n "$G" ] && [ -f "$G" ]; then
        "$TOOL" "$G" "$mode/$n" >> "$OUT.gold.txt" 2>&1 || fail=$((fail+1))
      fi
    fi
    proc=$((proc+1))
  done
done
echo "ACCOUNTING PASS  LISTED=$listed PROCESSED=$proc SKIPPED=$skip TOOLFAIL=$fail"
