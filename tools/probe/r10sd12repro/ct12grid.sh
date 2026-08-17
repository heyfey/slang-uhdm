#!/usr/bin/env bash
# r10sd12 grid driver.  Runs every grid12 cell on BOTH binaries and scores each
# one on THREE measures, not one:
#   * the whole-design uhdm-cmp verdict (PASS_CMP / CMP_FAIL) + head count,
#   * the DUMP CONTENT count (`diff -u` +/- lines, header excluded),
#   * THE ELEMENT-KIND TABLE, golden vs ours, row by row — which is the one that
#     decides here, because a cell can stay CMP_FAIL on both binaries for an
#     unrelated reason and still be the cell that proves or refutes the law.
#
# The element-kind table is `<array_var fullname>@line:col -> <element classes>`
# for every `array_var` in the dump, read out of the uhdm-dump TEXT (so the same
# script scores both sides of a cell one binary cannot produce an object for),
# and it is INDENTATION-SCOPED: an array_var's element variables are the
# `vpiReg:`-listed children, i.e. the lines strictly more indented than the
# array_var line and before the next line at or below its indentation.
#
# WHY NOT ct10pred: the array_var and its element share vpiFullName AND
# line:col, so a (fullname, line:col) join calls the whole population AMBIGUOUS.
# See ct12pred.cpp's header — the same reason, the same fix.
#
#   usage: PRIS=<pristine binary> PATCHED=<patched binary> ./ct12grid.sh [cell...]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?set PRIS to the pristine binary}
PATCHED=${PATCHED:?set PATCHED to the patched binary}
CELLS=${*:-}
if [ -z "$CELLS" ]; then
  CELLS=$(cd "$HERE/grid12" && ls *.sv)
fi
elemtab() {
  python3 - "$1" <<'PY'
import sys
lines = open(sys.argv[1]).read().split('\n')
def ind(l):
    return len(l) - len(l.lstrip(' |\\_'))
out = {}
for i, l in enumerate(lines):
    if 'array_var: (' not in l:
        continue
    nm = l.split('array_var: (', 1)[1].split(')', 1)[0]
    loc = ''
    if ', line:' in l:
        loc = l.split(', line:', 1)[1].split(',')[0]
    base = ind(l)
    kids = []
    inreg = False
    for j in range(i + 1, len(lines)):
        lj = lines[j]
        if not lj.strip():
            break
        if ind(lj) <= base and lj.strip().startswith('\\_'):
            break
        s = lj.strip()
        if s.startswith('|vpiReg:'):
            inreg = True
            continue
        if s.startswith('|vpi') and s != '|vpiReg:':
            inreg = False
            continue
        if inreg and s.startswith('\\_'):
            kids.append(s[2:].split(':', 1)[0])
    # THE SAME array_var is decompiled more than once (its declaration and, for
    # example, the lhs of the assignment that declares it), and the repeat
    # prints no vpiReg at all.  Merging on the key and letting a REAL element
    # list win over `<none>` is the only honest reading; two DIFFERENT real
    # lists under one key is a contradiction and is printed as such rather than
    # silently resolved.
    key = '%s@%s' % (nm, loc)
    val = ','.join(kids) if kids else '<none>'
    if key in out and out[key] != val:
        if out[key] == '<none>':
            out[key] = val
        elif val != '<none>':
            out[key] = '<AMBIGUOUS>'
    else:
        out[key] = val
for k in sorted(out):
    print('%s -> %s' % (k, out[k]))
PY
}
for c in $CELLS; do
  b=${c%.sv}
  echo "======== $b"
  for arm in pris patched; do
    if [ "$arm" = pris ]; then BIN=$PRIS; else BIN=$PATCHED; fi
    D=/tmp/r10sd12_grid_${arm}_$b
    out=$(SLANG_UHDM="$BIN" "$HERE/ct8arm.sh" "grid12/$c" "$D" 2>&1)
    verdict=$(echo "$out" | grep -E '^(PASS_CMP|CMP_FAIL|SURELOG_FAIL|NO_OUTPUT)')
    heads=$(echo "$out" | grep '^cmp heads=')
    content=$(echo "$out" | grep -E '^(DUMP_MATCH|DUMP_DIFF)')
    echo "  [$arm] $verdict | $heads | $content"
    if [ -f "$D/g.dump" ] && [ -f "$D/o.dump" ]; then
      # LC_ALL=C: comm compares BYTEWISE and a locale-collated sort silently
      # reports every row as differing (the trap ct11grid.sh hit first).
      elemtab "$D/g.dump" | LC_ALL=C sort > "$D/g.el"
      elemtab "$D/o.dump" | LC_ALL=C sort > "$D/o.el"
      gv=$(wc -l < "$D/g.el")
      n=$(comm -3 "$D/g.el" "$D/o.el" | wc -l)
      echo "  [$arm] ELEM golden_rows=$gv differing_sides=$n"
      [ "$gv" -gt 0 ] && \
        echo "" > /dev/null || \
        echo "  [$arm] REFUSING TO REPORT: the cell emits no array_var at all"
      comm -3 "$D/g.el" "$D/o.el" | sed "s/^/    [$arm] /"
    fi
  done
done
