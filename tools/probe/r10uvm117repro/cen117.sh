#!/usr/bin/env bash
# r10uvm117repro/cen117.sh — THE IMPLICIT-NET POPULATION CENSUS, per top module,
# golden-vs-ours, over a NAMED set of tests in a verify_golden workdir.
# MEASUREMENT ONLY (the official uhdm-cmp is the judge).
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
#   cen117.sh <sweep workdir> <cen bin> <outdir> <name> [<name> ...]
#
# For each <mode>/<name> found it censuses BOTH databases with ct117cen and
# writes <outdir>/<mode>.<name>.{g,o}.txt.  The golden path is read out of the
# workdir's own cmds.txt (never guessed), and a missing side is reported, never
# silently skipped.
set -u
WD=${1:?workdir}; CEN=${2:?cen bin}; OUT=${3:?outdir}; shift 3
mkdir -p "$OUT" || exit 1
: > "$OUT/cen.cmds.txt"
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      O=$d/slang.uhdm; C=$d/cmds.txt; G=""
      [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
        echo "MISSING $mode/$n g=${G:-none} o=$O" >> "$OUT/cen.cmds.txt"; continue
      fi
      "$CEN" "$G" G > "$OUT/$mode.$n.g.txt" 2>>"$OUT/cen.err"
      echo "rc=$? cen G $mode/$n $G" >> "$OUT/cen.cmds.txt"
      "$CEN" "$O" O > "$OUT/$mode.$n.o.txt" 2>>"$OUT/cen.err"
      echo "rc=$? cen O $mode/$n $O" >> "$OUT/cen.cmds.txt"
    done
  done
done
grep -c . "$OUT/cen.cmds.txt"
