#!/usr/bin/env bash
# r10uvm188repro/cen188.sh — the corpus-wide enum-constant census.
#
# MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# For every test directory in a verify_golden workdir this runs ct188cen over
# BOTH the golden database (found through that test's OWN cmds.txt, never a
# guessed cache path) and ours, tagging each row with <mode>/<test>.  A test
# whose golden or slang database is missing is COUNTED and named, never
# silently skipped — uhdm-cmp exits 0 on a missing input and a driver that
# reaches nothing must not read as perfection.
#
#   usage: CEN=<ct188cen> cen188.sh <workdir> <out-prefix>
# writes <out-prefix>.g.cen (golden) and <out-prefix>.o.cen (ours)
set -u
WD=${1:?workdir}
OUT=${2:?out prefix}
CEN=${CEN:?path to ct188cen}
[ -x "$CEN" ] || { echo "FATAL: no ct188cen at $CEN"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
: > "$OUT.g.cen"; : > "$OUT.o.cen"
seen=0; nog=0; noo=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    seen=$((seen+1))
    t=$(basename "$d")
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -n "$G" ] && [ -f "$G" ]; then "$CEN" "$G" "$mode/$t" >> "$OUT.g.cen" 2>/dev/null || true
    else nog=$((nog+1)); fi
    if [ -f "$d/slang.uhdm" ]; then "$CEN" "$d/slang.uhdm" "$mode/$t" >> "$OUT.o.cen" 2>/dev/null || true
    else noo=$((noo+1)); fi
  done
done
echo "-- dirs=$seen no-golden=$nog no-ours=$noo  golden rows=$(wc -l < "$OUT.g.cen")  our rows=$(wc -l < "$OUT.o.cen")"
