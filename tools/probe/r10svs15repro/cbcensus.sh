#!/usr/bin/env bash
# r10svs15 — THE CENSUS, BOTH SIDES, SPAN-KEYED, PRINTED AS ONE TABLE.
#
#   usage: ./cbcensus.sh <g.dump> <o.dump>
#
# WHAT A CELL IS.  One clocking-block EVENT-EXPRESSION `ref_obj` — the
# `@(posedge clock)` reference inside a NAMED clocking block — identified by its
# `vpiFullName` (which already encodes the VIEW: `work@<def>.cb.<sig>` is the DEF
# view, `work@top.<inst>.cb.<sig>` an ELAB/home view).  The VALUE of the cell is
# its `vpiActual` target, printed as `<uhdm class> <fullname>` or `-` when the ref
# is UNBOUND.  BOTH SIDES are read from dumps ALREADY ON DISK, so the table is
# re-readable without re-running any tool.
#
# WHY THE CENSUS IS SPAN-KEYED AS WELL AS NAME-KEYED.  Two views of the same
# clocking block carry the SAME source span (`line:63:24, endln:63:29` for all
# five `output_interface` views on the witness), so the span alone cannot key a
# cell; the FULLNAME alone can, but a fullname collision across two dumps that
# disagree on naming would silently pair the wrong cells.  So the key printed
# here is the PAIR (fullname, span), and a cell present on one side only is
# reported as `MISSING` rather than skipped -- a census that drops a row reads
# exactly like a census where the row agrees.
#
# TRAPS ENCODED
#   * uhdm-dump's FIRST LINE is the database path; both inputs must ALREADY be
#     `sed 1d`-ed (svsgen.sh and svs15arm.sh both do).  This script does not
#     re-strip, so a raw dump is a visible extra row, never a silent shift.
#   * `vpiActual` on a `ref_obj` is the NEXT `\_<class>:` line after the
#     `|vpiActual:` label AT A DEEPER INDENT.  A ref with no `vpiActual` label at
#     all is UNBOUND; the parser therefore keys on the LABEL, and stops at the
#     ref's own indent level so a SIBLING object's `vpiActual` can never be
#     misattributed.
#   * an empty or missing input is exit 6, never an empty table.
set -u
G=${1:?golden dump}
O=${2:?ours dump}
for f in "$G" "$O"; do
    [ -s "$f" ] || { echo "NO_OUTPUT: missing or empty $f"; exit 6; }
done
python3 - "$G" "$O" <<'PY'
import re, sys

REF = re.compile(r'^(\s*)\\_ref_obj: \(([^)]*)\), (line:\S+ endln:\S+|line:\S+, endln:\S+)\s*$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
OBJ = re.compile(r'^(\s*)\\_(\w+): (\([^)]*\))?(.*)$')


def scan(path):
    """Every clocking-event ref_obj in the file, keyed (fullname, span)."""
    lines = open(path, errors='replace').read().split('\n')
    out = {}
    for i, ln in enumerate(lines):
        m = REF.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        # Walk the ref's own field block: fields sit at ind+2, nested objects
        # deeper.  Stop at the first line whose indent is <= ind.
        full, actual, parent = None, None, None
        j = i + 1
        pend = None
        while j < len(lines):
            cur = lines[j]
            if cur.strip() == '':
                j += 1
                continue
            lead = len(cur) - len(cur.lstrip())
            if lead <= ind:
                break
            f = FLD.match(cur)
            if f and lead == ind + 2:
                if f.group(2) == 'vpiFullName':
                    full = f.group(3)
                pend = f.group(2)
                j += 1
                continue
            o = OBJ.match(cur)
            if o and lead == ind + 2:
                if pend == 'vpiActual':
                    nm = (o.group(3) or '()')[1:-1]
                    actual = '%s %s' % (o.group(2), nm if nm else '<anon>')
                elif pend == 'vpiParent':
                    parent = o.group(2)
                pend = None
            j += 1
        if full is None:
            continue
        # A clocking EVENT ref parents at an `operation` (posedge/negedge) or
        # directly at the event_control; a clocking_io_decl ref does not appear
        # as a bare ref_obj at all.  Keep every ref whose name has `.cb.`-style
        # clocking-block ownership OR whose parent is an operation/event_control,
        # and let the caller grep -- narrowing here would hide a shape.
        out[(full, m.group(3))] = (actual, parent)
    return out


g, o = scan(sys.argv[1]), scan(sys.argv[2])
keys = sorted(set(g) | set(o))
print('%-46s %-26s %-34s %-34s %s'
      % ('REF FULLNAME', 'SPAN', 'GOLDEN vpiActual', 'OURS vpiActual', 'V'))
nd = ne = nm = 0
for k in keys:
    gv = g.get(k)
    ov = o.get(k)
    ga = '-' if gv is None else (gv[0] or '(unbound)')
    oa = '-' if ov is None else (ov[0] or '(unbound)')
    if gv is None or ov is None:
        v = 'MISSING'
        nm += 1
    elif gv[0] == ov[0]:
        v = 'EQ'
        ne += 1
    else:
        v = 'DIF'
        nd += 1
    print('%-46s %-26s %-34s %-34s %s' % (k[0][:46], k[1][:26], ga[:34], oa[:34], v))
print('CELLS %d   EQ %d   DIF %d   MISSING %d' % (len(keys), ne, nd, nm))
PY
