#!/usr/bin/env bash
# r10sd11 grid driver.  Runs every grid11 cell on BOTH binaries and scores each
# one on THREE measures, not one:
#   * the whole-design uhdm-cmp verdict (PASS_CMP / CMP_FAIL) + head count,
#   * the DUMP CONTENT count (`diff -u` +/- lines, header excluded),
#   * THE BOUND-TYPESPEC TABLE, golden vs ours, row by row — which is the one
#     that decides here, because a cell can stay CMP_FAIL on both binaries for
#     an unrelated reason and still be the cell that proves or refutes the law.
#
# The typespec table is `<variable fullname> -> <typespec class> (<name>)` for
# every variable whose ref_typespec names an actual, so a cell with ZERO
# differing rows is reported as EXACT and a cell whose rows only MOVE has the
# moved rows printed, never summarised.
#
#   usage: PRIS=<pristine binary> PATCHED=<patched binary> ./ct11grid.sh [cell...]
set -u
GD=${GD:-grid11}
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?set PRIS to the pristine binary}
PATCHED=${PATCHED:?set PATCHED to the patched binary}
CELLS=${*:-}
if [ -z "$CELLS" ]; then
  CELLS=$(cd "$HERE/$GD" && ls *.sv)
fi
# `<var fullname> <ts class> (<ts name>) @line:col`, read out of the uhdm-dump
# text by pairing each variable with the `vpiActual` line that follows its
# `vpiTypespec`.  Text, not the API, so the same script scores both sides of a
# cell that one binary cannot even produce an object for.
tstab() {   # LC_ALL=C: comm compares BYTEWISE, and a locale-collated sort silently
            # reports every row as differing (the trap this script hit first).
  python3 - "$1" <<'PY'
import sys
lines = open(sys.argv[1]).read().split('\n')
out = set()
for i, l in enumerate(lines):
    if '_var: (' not in l or '\\_' not in l:
        continue
    nm = l.split('_var: (', 1)[1].split(')', 1)[0]
    if '::' not in nm:
        continue
    ind = len(l) - len(l.lstrip())
    for j in range(i + 1, min(i + 12, len(lines))):
        lj = lines[j]
        if lj.strip().startswith('|vpi') and (len(lj) - len(lj.lstrip())) < ind:
            break
        if 'vpiActual' in lj and j + 1 < len(lines):
            t = lines[j + 1].strip()
            out.add('%s -> %s' % (nm, t.lstrip('\\_')))
            break
for r in sorted(out):
    print(r)
PY
}
for c in $CELLS; do
  b=${c%.sv}
  echo "======== $b"
  for arm in pris patched; do
    if [ "$arm" = pris ]; then BIN=$PRIS; else BIN=$PATCHED; fi
    D=/tmp/vsd11_grid_${arm}_$b
    out=$(SLANG_UHDM="$BIN" "$HERE/ct8arm.sh" "$GD/$c" "$D" 2>&1)
    verdict=$(echo "$out" | grep -E '^(PASS_CMP|CMP_FAIL|SURELOG_FAIL|NO_OUTPUT)')
    heads=$(echo "$out" | grep '^cmp heads=')
    content=$(echo "$out" | grep -E '^(DUMP_MATCH|DUMP_DIFF)')
    echo "  [$arm] $verdict | $heads | $content"
    if [ -f "$D/g.dump" ] && [ -f "$D/o.dump" ]; then
      tstab "$D/g.dump" | LC_ALL=C sort > "$D/g.ts"
      tstab "$D/o.dump" | LC_ALL=C sort > "$D/o.ts"
      gv=$(wc -l < "$D/g.ts")
      n=$(comm -3 "$D/g.ts" "$D/o.ts" | wc -l)
      echo "  [$arm] TS golden_rows=$gv differing_sides=$n"
      [ "$gv" -gt 0 ] || echo "  [$arm] REFUSING TO REPORT: the cell binds no named variable typespec"
      comm -3 "$D/g.ts" "$D/o.ts" | sed "s/^/    [$arm] /"
    fi
  done
done
