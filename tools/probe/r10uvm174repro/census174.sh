#!/usr/bin/env bash
# r10uvm174repro/census174.sh — SCORE EVERY MOVER AGAINST GOLDEN.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.  LHS is ALWAYS
# golden (Surelog).
#
#   census174.sh <pristine workdir> <patched workdir> <outdir> <row> [<row> ...]
#
# For each named row and each mode it runs ct174cen over golden, the PRISTINE
# database and the PATCHED database, and scores the three-way join with
# score174.py — exact positions AND span-blind, both printed.
set -u
WA=${1:?pristine workdir}
WB=${2:?patched workdir}
OUT=${3:?outdir}
CEN=${CT174CEN:-/tmp/r10uvm174_ct174cen}
SELF=$(cd "$(dirname "$0")" && pwd)
shift 3
[ -x "$CEN" ] || { echo "FATAL: no ct174cen at $CEN"; exit 3; }
mkdir -p "$OUT"
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WA/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      OA=$d/slang.uhdm
      OB=$WB/$mode/$b/slang.uhdm
      C=$d/cmds.txt
      G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$OA" ] || [ ! -f "$OB" ]; then
        echo "SKIP-NOFILE $n $mode g=${G:-none} a=$OA b=$OB"
        continue
      fi
      W="$OUT/$n.$mode"; mkdir -p "$W"
      "$CEN" "$G"  > "$W/cen.g.def.txt"
      "$CEN" "$OA" > "$W/cen.a.def.txt"
      "$CEN" "$OB" > "$W/cen.b.def.txt"
      echo "== $n $mode"
      echo -n "   exact  "; python3 "$SELF/score174.py" "$W" --view def | tail -1
      echo -n "   nospan "; python3 "$SELF/score174.py" "$W" --view def --nospan | tail -1
    done
  done
done
