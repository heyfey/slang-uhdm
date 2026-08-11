#!/usr/bin/env bash
# ptab.sh -- join the two sides of a parm.sh workdir into ONE table, per
# (view, module, path) cell, and print UNMEASURED where a side has no row at all.
#
#   usage: ./ptab.sh /tmp/r10oth5_arm_p1_paramref [path-regex]
#
# LHS is ALWAYS golden; RHS is ALWAYS ours.  A cell present on exactly one side
# is a LIVE DIFFERENCE and prints as UNMEASURED on the missing side -- the thing
# r10oth4's rtab.sh could not do, and the reason its residue R1 got a guess
# instead of a measurement.
set -u
D=$1
RE=${2:-'vpi(Cont|Param)Assign\[[0-9]+\]/vpi(Rhs|Lhs)|vpiExpr|vpiVariables'}
[ -s "$D/g.tab" ] && [ -s "$D/o.tab" ] || { echo "MISSING TABS in $D"; exit 3; }
python3 - "$D" "$RE" <<'PY'
import sys, re
d, rex = sys.argv[1], re.compile(sys.argv[2])
def load(p):
    m = {}
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 7:
            continue
        view, mod, path, dr, kind, span, fields = f[:7]
        if not rex.search(path):
            continue
        m[(view, mod, path)] = (dr, kind, span, fields)
    return m
g, o = load(d + '/g.tab'), load(d + '/o.tab')
keys = sorted(set(g) | set(o))
if not keys:
    print('PTAB_BLIND: the path filter selected NOTHING on either side')
    sys.exit(3)
ndiff = 0
def fmt(v):
    return 'UNMEASURED(no such row on this side)' if v is None else \
           '%s %s %s %s' % v
for k in keys:
    gv, ov = g.get(k), o.get(k)
    view, mod, path = k
    mod = mod.split(' ')[0].replace('work@', '')
    if gv != ov:
        ndiff += 1
    print('%-14s %-24s %s' % (view[4:], mod, path))
    print('    G| %s' % fmt(gv))
    print('    O| %s%s' % (fmt(ov), '   *** DIFF' if gv != ov else ''))
print('CELLS=%d DIFFERING=%d' % (len(keys), ndiff))
PY
