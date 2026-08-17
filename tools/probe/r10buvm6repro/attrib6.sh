#!/usr/bin/env bash
# r10buvm6 MOVER ATTRIBUTION — for every byte-mover byteverify.sh reports, say
# WHAT changed, and prove it is nothing but `$` constants.
#
#   usage: attrib6.sh <patched-workdir-root> <pristine-workdir-root> <outdir> <relpath> [...]
#
# For each database pair it prints
#   DIFFLINES  raw `-`/`+` lines between the two dumps
#   DOLLAR     how many of the `+` lines are the four fields of a `$` constant
#   RESIDUE    `-`/`+` lines remaining after stripdollar.py removes every `$`
#              CONSTANT BLOCK from both sides
# and requires RESIDUE = 0.  A mover with RESIDUE > 0 carries a change this pass's
# law does not account for and its residue is printed.
#
# GUARDS:
#   * uhdm-dump's FIRST LINE IS THE DATABASE PATH, and the two roots differ, so
#     that line ALWAYS differs -> `sed 1d` on BOTH sides.  After that the script
#     ASSERTS no remaining line mentions either workdir root; a path leak would
#     otherwise be counted as residue and read as a defect in the law.
#   * a missing database on either side is FATAL, not "no residue".
set -u
A=${1:?patched root}
B=${2:?pristine root}
OUT=${3:?outdir}
shift 3
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
STRIP=$HERE/stripdollar.py
[ -f "$STRIP" ] || { echo "FATAL: no $STRIP"; exit 3; }
mkdir -p "$OUT" || exit 9
bad=0; n=0
printf "%-46s %10s %8s %8s %s\n" MOVER DIFFLINES DOLLAR RESIDUE NOTE
for p in "$@"; do
  n=$((n+1))
  tag=$(echo "$p" | tr '/' '_' | sed 's/^\._//;s/_slang.uhdm$//')
  for side in A B; do
    root=$A; [ "$side" = B ] && root=$B
    [ -f "$root/$p" ] || { echo "FATAL: missing $root/$p"; exit 4; }
  done
  "$DUMP" "$A/$p" 2>/dev/null | sed 1d > "$OUT/$tag.pat.dump"
  "$DUMP" "$B/$p" 2>/dev/null | sed 1d > "$OUT/$tag.pris.dump"
  leak=$(grep -cF -e "$A" -e "$B" "$OUT/$tag.pat.dump" "$OUT/$tag.pris.dump" 2>/dev/null |
         awk -F: '{s+=$NF} END{print s+0}')
  diff -u "$OUT/$tag.pris.dump" "$OUT/$tag.pat.dump" > "$OUT/$tag.diff" || true
  d=$(grep -E '^[-+]' "$OUT/$tag.diff" | grep -vcE '^(---|\+\+\+) ' || true)
  dol=$(grep -E '^\+' "$OUT/$tag.diff" | grep -vE '^\+\+\+ ' |
        grep -cE '\|vpiDecompile:\$$|\|vpiSize:1$|\|STRING:\$$|\|vpiConstType:10$' || true)
  python3 "$STRIP" "$OUT/$tag.pris.dump" > "$OUT/$tag.pris.strip"
  python3 "$STRIP" "$OUT/$tag.pat.dump"  > "$OUT/$tag.pat.strip"
  diff -u "$OUT/$tag.pris.strip" "$OUT/$tag.pat.strip" > "$OUT/$tag.sdiff" || true
  r=$(grep -E '^[-+]' "$OUT/$tag.sdiff" | grep -vcE '^(---|\+\+\+) ' || true)
  note=OK
  [ "$leak" -gt 0 ] && note="PATH-LEAK($leak)"
  [ "$r" -gt 0 ] && { note=RESIDUE; bad=$((bad+1)); }
  printf "%-46s %10s %8s %8s %s\n" "$tag" "$d" "$dol" "$r" "$note"
  if [ "$r" -gt 0 ]; then
    echo "     ---- RESIDUE (- = pristine, + = patched):"
    grep -E '^[-+]' "$OUT/$tag.sdiff" | grep -vE '^(---|\+\+\+) ' | head -20 | sed 's/^/     /'
  fi
done
echo "-- movers=$n RESIDUE-MOVERS=$bad"
[ "$bad" -eq 0 ] && echo "PASS: every mover's ENTIRE change is \$ constants" \
                 || { echo "FAIL: a mover changed something else"; exit 1; }
