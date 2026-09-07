#!/usr/bin/env bash
# r10uvm194repro/cen194.sh — the corpus census driver.  MEASUREMENT ONLY.
#
#   CEN=<ct194cen> cen194.sh <verify_golden workdir> <outdir> [name ...]
#
# With no names it walks EVERY row of the workdir; with names, only those.
# The golden is read out of each row's OWN cmds.txt (never guessed from a test
# name), and a row whose golden or database is missing is printed as SKIP and
# COUNTED — a driver that reaches nothing must never read as perfection.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
CEN=${CEN:?set CEN to the built ct194cen}
mkdir -p "$OUT" || exit 1
skip=0; done_=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    row=$(basename "$d")
    if [ $# -gt 0 ]; then
      hit=0
      for n in "$@"; do case "$row" in "$n"-*) hit=1;; esac; done
      [ "$hit" = 1 ] || continue
    fi
    O=$d/slang.uhdm; C=$d/cmds.txt; G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP $mode $row"; skip=$((skip+1)); continue
    fi
    "$CEN" "$G" g > "$OUT/$row.$mode.g.txt" 2>/dev/null
    grc=$?
    "$CEN" "$O" o > "$OUT/$row.$mode.o.txt" 2>/dev/null
    orc=$?
    echo "ROW $mode $row grc=$grc orc=$orc g=$(wc -l < "$OUT/$row.$mode.g.txt") o=$(wc -l < "$OUT/$row.$mode.o.txt")"
    done_=$((done_+1))
  done
done
echo "-- rows=$done_ SKIP=$skip"
