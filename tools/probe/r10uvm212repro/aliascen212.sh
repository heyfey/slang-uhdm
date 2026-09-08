#!/bin/bash
# r10uvm212 — run ct212alias over the UVM row-modes of a verify_golden workdir,
# GOLDEN side and OURS side, and print the clone/base listing mismatch count for
# each.  MEASUREMENT ONLY.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# THE INVARIANT THIS MEASURES: `clone_tree` (Surelog
# ElaborationStep.cpp:193-200) copies the base wholesale, so in GOLDEN a
# class_typespec that carries a `vpiTypedefAlias` always has EXACTLY its base's
# `Parameters`/`Param_assigns` — present or ABSENT.  golden must read 0
# mismatches on every row; ours is the number under test.
#
# GUARDS: the golden path is read from the row's OWN cmds.txt; a row missing
# either side prints SKIP-NOFILE and is COUNTED; the workdir is an argument.
#
#   usage: CT212ALIAS=<bin> aliascen212.sh <workdir>
set -u
WD=${1:?workdir}
AL=${CT212ALIAS:?set CT212ALIAS to the built ct212alias}
miss=0; did=0; gbad=0; obad=0
printf "%-14s %-9s %10s %10s\n" TEST MODE GOLDEN_MM OURS_MM
for t in Scoreboard SeqDriver MiniAmiq SimpleUVM BuildUVMPkg; do
  for m in default testflags; do
    D=$(ls -d "$WD/$m/$t"-*/ 2>/dev/null | head -1)
    [ -n "$D" ] || { printf "%-14s %-9s %10s %10s  SKIP-NOFILE(no row dir)\n" "$t" "$m" - -; miss=$((miss+1)); continue; }
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)
    if [ -z "$G" ] || [ ! -f "$G/golden.uhdm" ] || [ ! -f "$D/slang.uhdm" ]; then
      printf "%-14s %-9s %10s %10s  SKIP-NOFILE(g=%s)\n" "$t" "$m" - - "${G:-none}"
      miss=$((miss+1)); continue
    fi
    g=$("$AL" "$G/golden.uhdm" | sed -n 's/.*MISMATCHES=\([0-9]*\).*/\1/p' | head -1)
    o=$("$AL" "$D/slang.uhdm"  | sed -n 's/.*MISMATCHES=\([0-9]*\).*/\1/p' | head -1)
    printf "%-14s %-9s %10s %10s\n" "$t" "$m" "${g:-?}" "${o:-?}"
    gbad=$((gbad + ${g:-0})); obad=$((obad + ${o:-0})); did=$((did+1))
  done
done
echo "-- measured=$did SKIP-NOFILE=$miss  GOLDEN mismatches total=$gbad  OURS total=$obad"
[ "$did" -gt 0 ] || { echo "GATE FAIL: measured nothing"; exit 4; }
