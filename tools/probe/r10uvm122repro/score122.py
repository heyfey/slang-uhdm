#!/usr/bin/env python3
"""r10uvm122 — score one arm's cells: golden vs pristine vs patched.

  score122.py <g.cells> <pris.cells> [<pat.cells>] <label>

Cells are keyed on (ref kind, ref name, ref span) — never on a fullname, never
on a file path.  The VALUE is the actual-object string.  A key present on only
one side is reported as a ONE-SIDED cell, because a pass that REMOVES or ADDS
objects must score one-sided sets (uvm109's law).
"""
import sys
from collections import Counter


def load(p):
    d = {}
    if not p:
        return d
    for l in open(p, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 5:
            continue
        d[(f[1], f[2], f[3])] = (int(f[0]), f[4])
    return d


g, pr, pa = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
label = sys.argv[4]
keys = sorted(set(g) | set(pr) | set(pa))
c = Counter()
detail = []
for k in keys:
    gv, pv, av = g.get(k), pr.get(k), pa.get(k)
    if gv is None or pv is None:
        c['ONESIDED_PRIS'] += 1
        detail.append(('ONESIDED_PRIS', k, gv, pv, av))
        continue
    agree_p = (gv == pv)
    if not sys.argv[3]:
        c['AGREE' if agree_p else 'DIFF'] += 1
        if not agree_p:
            detail.append(('DIFF', k, gv, pv, av))
        continue
    if av is None:
        c['ONESIDED_PAT'] += 1
        detail.append(('ONESIDED_PAT', k, gv, pv, av))
        continue
    agree_a = (gv == av)
    if pv == av:
        c['SAME_AGREE' if agree_a else 'SAME_DIFF'] += 1
        if not agree_a:
            detail.append(('SAME_DIFF', k, gv, pv, av))
    elif agree_a:
        c['TOGOLD'] += 1
        detail.append(('TOGOLD', k, gv, pv, av))
    elif agree_p:
        c['MOVEDWRONG'] += 1
        detail.append(('MOVEDWRONG', k, gv, pv, av))
    else:
        c['MOVEDOTHER'] += 1
        detail.append(('MOVEDOTHER', k, gv, pv, av))
print('%-26s %s' % (label, ' '.join('%s=%d' % kv for kv in sorted(c.items()))))
for tag, k, gv, pv, av in detail:
    print('   %-12s %s %s %s\n        golden=%s\n        pris  =%s%s'
          % (tag, k[0], k[1], k[2],
             gv[1] if gv else '<absent>', pv[1] if pv else '<absent>',
             ('\n        pat   =%s' % (av[1] if av else '<absent>'))
             if sys.argv[3] else ''))
