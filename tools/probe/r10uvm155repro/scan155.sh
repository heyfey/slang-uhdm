#!/bin/bash
# r10uvm155 — census a verify_golden workdir's rows (golden AND ours) with
# ct155cen and JOIN them per row-mode.  MEASUREMENT ONLY; the official uhdm-cmp
# is the judge.  LHS/G is ALWAYS golden (Surelog); RHS/O is ALWAYS ours.
#
#   usage: CEN=<ct155cen> scan155.sh <workdir> <outdir> <name> [<name> ...]
#
# GUARDS: a missing golden or a missing slang.uhdm prints SKIP-NOFILE and is
# COUNTED (uhdm-cmp exits 0 on a missing file and so does a silent census);
# the golden path is read out of the row's OWN cmds.txt; scratch is keyed on
# <name>.<mode> so two rows of the same name in different modes cannot collide.
set -u
CEN=${CEN:?ct155cen}
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
mkdir -p "$OUT" || exit 1
miss=0; found=0
for n in "$@"; do
  for mode in default testflags; do
    for d in "$WD/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      G=""
      [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$d/slang.uhdm" ]; then
        echo "SKIP-NOFILE $n $mode"; miss=$((miss+1)); continue
      fi
      "$CEN" "$G" G > "$OUT/$n.$mode.g.tsv"
      "$CEN" "$d/slang.uhdm" O > "$OUT/$n.$mode.o.tsv"
      found=$((found+1))
      echo "CENSUSED $n $mode g=$(wc -l < "$OUT/$n.$mode.g.tsv") o=$(wc -l < "$OUT/$n.$mode.o.tsv")"
    done
  done
done
echo "-- censused=$found SKIP-NOFILE=$miss"
