#!/usr/bin/env python3
"""r10uvm163 — score163.py: join a GOLDEN ct163cen listing against an OURS one
and classify every declaration-site class_typespec cell.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  MEASUREMENT ONLY.

    usage: score163.py <g.cen> <o.cen> [--cells]
           score163.py --selftest

Classes (the judge reads `class_typespec::Compare`'s Parameters and
Param_assigns VECTORS, so a NULL and an EMPTY vector are the same cell to it —
`ct163cen` prints nparam=-1 for null and 0 for empty and this scorer folds them
together with `norm()`):

  RIGHT     the listings agree (same param count and same name:kind:name list)
  WRONG     golden has a listing, ours has none          <- the target
  RESHAPE   both have listings and they differ
  AWAY      golden has NO listing and ours has one       <- must stay 0
  ONLY-G    a key golden has and we do not (a parenting / owner-kind residue)
  ONLY-O    a key we have and golden does not

GUARDS:
  * the join is a MULTISET join.  Golden repeats a key up to four times (a
    package variable's declaration typespec is cloned per elaborated copy), so
    a dict keyed on the cell would DROP rows and a set join would then
    manufacture ONLY-G phantoms (RESUME.md §9, census traps).  Rows sharing a
    key are SORTED on both sides and paired POSITIONALLY; the surplus on either
    side becomes ONLY-G / ONLY-O;
  * refuses two files that both parse to zero cells;
  * --selftest is the positive control: a fixture with one of each class, plus
    a key carried 3x on one side and 2x on the other.
"""
import re
import sys

CELL = re.compile(r'^CELL (.*?) \| nparam=(-?\d+) \| params=(.*?) \| npa=(-?\d+) \| '
                  r'holder=(\S+) \|(?: cdefn=(\S*) \| cdp=(-?\d+) \|)? home=(.*)$')


def load(path):
    cells = {}
    with open(path) as f:
        for ln in f:
            m = CELL.match(ln.rstrip('\n'))
            if not m:
                continue
            cells.setdefault(m.group(1), []).append(
                (int(m.group(2)), m.group(3), int(m.group(4)),
                 m.group(5), m.group(8), m.group(6) or '', int(m.group(7) or 0)))
    for v in cells.values():
        v.sort()
    return cells


def norm(n):
    """A NULL vector and an EMPTY vector are one cell to UHDM's SafeCompare."""
    return 0 if n <= 0 else n


def classify(g, o):
    gn, gp = norm(g[0]), g[1]
    on, op = norm(o[0]), o[1]
    if gn == 0 and on == 0:
        return 'RIGHT'
    if gn > 0 and on == 0:
        return 'WRONG'
    if gn == 0 and on > 0:
        return 'AWAY'
    return 'RIGHT' if (gn == on and gp == op) else 'RESHAPE'


def score(gpath, opath, show):
    g = load(gpath)
    o = load(opath)
    if not g and not o:
        print('FATAL: both listings parsed to ZERO cells')
        return 4
    hist = {}
    rows = []
    for k in sorted(set(g) | set(o)):
        gl, ol = g.get(k, []), o.get(k, [])
        n = min(len(gl), len(ol))
        for i in range(n):
            c = classify(gl[i], ol[i])
            rows.append((c, k, gl[i], ol[i]))
            hist[c] = hist.get(c, 0) + 1
        for i in range(n, len(gl)):
            rows.append(('ONLY-G', k, gl[i], None))
            hist['ONLY-G'] = hist.get('ONLY-G', 0) + 1
        for i in range(n, len(ol)):
            rows.append(('ONLY-O', k, None, ol[i]))
            hist['ONLY-O'] = hist.get('ONLY-O', 0) + 1
    if show:
        for c, k, gv, ov in rows:
            if c == 'RIGHT':
                continue
            print(f'{c:8s} {k}')
            if gv:
                print(f'         G nparam={gv[0]} params={gv[1]} npa={gv[2]} home={gv[4]}')
            if ov:
                print(f'         O nparam={ov[0]} params={ov[1]} npa={ov[2]} home={ov[4]}')
    print('SCORE ' + ' '.join(f'{k}={hist.get(k,0)}' for k in
                              ('RIGHT', 'WRONG', 'RESHAPE', 'AWAY', 'ONLY-G', 'ONLY-O')) +
          f' TOTAL={len(rows)}')
    return 0


def selftest():
    import tempfile
    import os
    g = ['CELL a@1:1|va | nparam=2 | params=T:int_typespec:,I:class_typespec:c | npa=2 | holder=class_var | home=<x',
         'CELL b@2:1|vb | nparam=-1 | params= | npa=-1 | holder=class_var | home=<x',
         'CELL c@3:1|vc | nparam=1 | params=T:int_typespec: | npa=1 | holder=class_var | home=<x',
         'CELL d@4:1|vd | nparam=1 | params=T:int_typespec: | npa=1 | holder=class_var | home=<x',
         'CELL e@5:1|ve | nparam=-1 | params= | npa=-1 | holder=class_var | home=<x',
         'CELL g@7:1|vg | nparam=0 | params= | npa=0 | holder=class_var | home=<x',
         'CELL h@8:1|vh | nparam=1 | params=T:int_typespec: | npa=1 | holder=class_var | home=<x',
         'CELL h@8:1|vh | nparam=1 | params=T:int_typespec: | npa=1 | holder=class_var | home=<x',
         'CELL h@8:1|vh | nparam=1 | params=T:int_typespec: | npa=1 | holder=class_var | home=<x']
    o = ['CELL a@1:1|va | nparam=2 | params=T:int_typespec:,I:class_typespec:c | npa=2 | holder=class_var | home=<x',
         'CELL b@2:1|vb | nparam=1 | params=T:int_typespec: | npa=1 | holder=class_var | home=<x',
         'CELL c@3:1|vc | nparam=-1 | params= | npa=-1 | holder=class_var | home=<x',
         'CELL d@4:1|vd | nparam=2 | params=T:int_typespec:,U:int_typespec: | npa=2 | holder=class_var | home=<x',
         'CELL f@6:1|vf | nparam=-1 | params= | npa=-1 | holder=class_var | home=<x',
         'CELL g@7:1|vg | nparam=-1 | params= | npa=-1 | holder=class_var | home=<x',
         'CELL h@8:1|vh | nparam=1 | params=T:int_typespec: | npa=1 | holder=class_var | home=<x',
         'CELL h@8:1|vh | nparam=-1 | params= | npa=-1 | holder=class_var | home=<x']
    d = tempfile.mkdtemp(prefix='sc163_')
    gp, op = os.path.join(d, 'g'), os.path.join(d, 'o')
    open(gp, 'w').write('\n'.join(g) + '\n')
    open(op, 'w').write('\n'.join(o) + '\n')
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        score(gp, op, False)
    out = buf.getvalue().strip()
    want = 'SCORE RIGHT=3 WRONG=2 RESHAPE=1 AWAY=1 ONLY-G=2 ONLY-O=1 TOTAL=10'
    # RIGHT: a (identical), g (golden EMPTY vs ours NULL -> the same cell to the
    # judge) and one of key h's three golden rows; key h also proves the
    # multiset join: 3 golden rows against 2 of ours give WRONG + RIGHT + ONLY-G
    # rather than one row and two dropped ones.
    ok = out == want
    print(out)
    print('SELFTEST ' + ('PASS' if ok else f'FAIL want[{want}]'))
    return 0 if ok else 1


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(2)
    sys.exit(score(sys.argv[1], sys.argv[2], '--cells' in sys.argv))
