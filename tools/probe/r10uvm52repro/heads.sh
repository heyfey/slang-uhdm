#!/bin/bash
# r10uvm52repro/heads.sh — print, for EVERY database left in a verify_golden
# workdir (NOT only the UVM ones: the pass-51 header said "UVM-4" and the
# integration corrected it — this loop walks the whole workdir, so pointing it
# at a full sweep costs a cmp per test), the cmp LINE COUNT, the HEAD COUNT and
# an id-normalised md5 of the head, so "do these rows share one head?" is a
# MEASUREMENT and not an impression.
#
# THE MD5 IS INSTRUMENT-LOCAL.  Quote the EQUALITY of two md5s, never the
# number: three agents computed three different normalised md5s for the same
# shape in pass 51 because they normalised differently.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  uhdm-cmp takes
# (golden.uhdm, ours.uhdm) in that order.
#
# GUARDS:
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING.  Every pair is existence-checked
#     and a missing side prints NO_OUTPUT instead of a verdict.
#   * heads are counted with `grep -c '^LHS:'` at column 0, because cmp prints
#     `decompile:` TWICE PER SIDE for ONE head.
#   * the golden path is read out of the workdir's own cmds.txt, so this script
#     cannot silently compare against the wrong golden.
#   * MEASURE THE MEASURER: a test whose golden or slang.uhdm cannot be found is
#     reported as SKIP-NOFILE and counted, so a driver that reaches nothing can
#     never read as perfection.
set -u
WD=${1:?workdir}
OUTDIR=${2:?outdir for per-test cmp text}
mkdir -p "$OUTDIR" || exit 1
found=0; missing=0
printf "%-14s %-9s %7s %6s %s\n" TEST MODE CMPLINES HEADS HEAD_MD5_IDNORM
for mode in default testflags; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    t=$(basename "$d"); t=${t%-*}
    O=$d/slang.uhdm
    C=$d/cmds.txt
    if [ ! -f "$C" ]; then printf "%-14s %-9s %7s %6s %s\n" "$t" "$mode" - - SKIP-NOCMDS; missing=$((missing+1)); continue; fi
    # the cmds.txt records the golden CACHE DIRECTORY; the database inside it is
    # golden.uhdm.  Resolving to the directory and handing THAT to uhdm-cmp is
    # how a run can silently compare nothing, so append the filename here.
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      printf "%-14s %-9s %7s %6s %s\n" "$t" "$mode" - - "SKIP-NOFILE(g=${G:-none})"
      missing=$((missing+1)); continue
    fi
    F=$OUTDIR/cmp_${mode}_${t}.txt
    uhdm-cmp "$G" "$O" > "$F" 2>&1
    L=$(wc -l < "$F"); H=$(grep -c '^LHS:' "$F")
    M=$(sed 's/id:[0-9]*/id:N/g' "$F" | md5sum | cut -d' ' -f1)
    printf "%-14s %-9s %7s %6s %s\n" "$t" "$mode" "$L" "$H" "$M"
    found=$((found+1))
  done
done
echo "---- measured=$found  skipped=$missing"
[ "$found" -gt 0 ] || { echo "REFUSING TO REPORT: reached no database"; exit 5; }
