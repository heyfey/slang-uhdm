#!/usr/bin/env bash
# r10uvm178repro/cen178.sh — the census driver.  MEASUREMENT ONLY; the official
# `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.
#
#   cen178.sh <workdir> <outdir> <cen bin> [--pref] [name ...]
#
# For every test directory in <workdir>/{default,testflags} (or only the named
# ones), runs the census on BOTH sides: the golden database named by that
# directory's OWN cmds.txt (never a guessed cache path) and our slang.uhdm.
# The run tag is <name>.<mode> — the DEF/ELAB view is NOT part of any key.
# A missing side is reported and COUNTED; it never reads as agreement.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; CEN=${3:?cen}; shift 3
PREF=""
if [ "${1:-}" = "--pref" ]; then PREF="--pref"; shift; fi
mkdir -p "$OUT" || exit 1
: > "$OUT/MISSING.txt"
n=0; miss=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    base=$(basename "$d"); name=${base%-*}
    if [ "$#" -gt 0 ]; then
      hit=0; for w in "$@"; do [ "$name" = "$w" ] && hit=1; done
      [ "$hit" = 1 ] || continue
    fi
    O=$d/slang.uhdm
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "MISSING $name $mode g=${G:-none} o=$O" >> "$OUT/MISSING.txt"
      miss=$((miss+1)); continue
    fi
    "$CEN" "$G" "$name.$mode" $PREF > "$OUT/g.$name.$mode.txt" 2>>"$OUT/cen.err"
    "$CEN" "$O" "$name.$mode" $PREF > "$OUT/o.$name.$mode.txt" 2>>"$OUT/cen.err"
    n=$((n+1))
  done
done
echo "censused=$n missing=$miss"
