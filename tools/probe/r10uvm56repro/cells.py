#!/usr/bin/env python3
"""r10uvm56repro/cells.py — the ARM CELL TABLE.

A CELL is one (view, owning routine, reference kind, reference name,
line:col).  For each cell both sides are printed: what golden's
`vpiActual` is and what ours is, read off the REFERENCE OBJECT ITSELF (own
child depth -- no nested object contributes).  Cells are split into
RETURN-NAME cells (the reference's name equals the last `::`/`.` segment of
its owning routine's fullname -- the implicit return variable) and LOCAL
cells (everything else, the positive control).

    cells.py <g.cen> <o.cen> [--all]

`--all` prints every cell; the default prints the return-name cells in full
and summarises the local cells (there are hundreds and they are the control).

GUARD: a cell present on only one side prints NOREF on that side and is
counted as DIFFERING -- never silently dropped, because "ours emits no
reference at all" is one of the residues this campaign has to rank.
"""
import re
import sys
from collections import defaultdict

LINE = re.compile(r"^(\S+) (\S+) \| (\S+) '([^']*)' (\d+:\d+) -> (.*) @ (.*)$")


def load(p):
    rows = {}
    for ln in open(p):
        m = LINE.match(ln.rstrip('\n'))
        if m:
            v, tf, k, n, pos, a, c = m.groups()
            rows[(v, tf, k, n, pos)] = (a, c)
    return rows


def lastseg(tf):
    s = tf
    for sep in ('::', '.'):
        if sep in s:
            s = s.split(sep)[-1]
    return s


def bound(a):
    return a is not None and a[0] not in (None, '-')


g = load(sys.argv[1])
o = load(sys.argv[2])
show_all = '--all' in sys.argv

keys = sorted(set(g) | set(o))
ret = [k for k in keys if k[3] and k[3] == lastseg(k[1])]
loc = [k for k in keys if k not in set(ret)]


def emit(title, ks, full):
    diff = 0
    print('--- %s: %d cells' % (title, len(ks)))
    if full:
        print('    %-9s %-34s %-7s %-9s %-24s %-24s %s'
              % ('VIEW', 'ROUTINE', 'KIND', 'AT', 'GOLDEN vpiActual',
                 'OURS vpiActual', 'VERDICT'))
    for k in ks:
        ga, oa = g.get(k), o.get(k)
        gb, ob = bound(ga), bound(oa)
        if ga is None or oa is None:
            verdict = 'NOREF-DIFF'
        elif gb and not ob:
            verdict = 'UNDERBIND'
        elif ob and not gb:
            verdict = 'OVERBIND'
        else:
            verdict = 'agree'
        if verdict != 'agree':
            diff += 1
        if full:
            print('    %-9s %-34s %-7s %-9s %-24s %-24s %s'
                  % (k[0], k[1][:34], k[2], k[4],
                     (ga[0] if ga else 'NOREF')[:24],
                     (oa[0] if oa else 'NOREF')[:24], verdict))
    print('    DIFFERING = %d / %d' % (diff, len(ks)))
    return diff


d1 = emit('RETURN-NAME cells', ret, True)
d2 = emit('LOCAL cells (positive control)', loc, show_all)
print('TOTAL DIFFERING = %d (return-name %d + local %d) over %d cells'
      % (d1 + d2, d1, d2, len(keys)))
