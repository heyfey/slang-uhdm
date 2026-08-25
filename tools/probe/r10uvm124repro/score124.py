#!/usr/bin/env python3
"""r10uvm124 — score one database's `method_func_call` cells: golden vs
PRISTINE vs (optionally) PATCHED.  MEASUREMENT ONLY; the official `uhdm-cmp`
is the judge.  LHS is ALWAYS golden.

  score124.py <g.cells> <pris.cells> [<pat.cells>] <label>

The join is a MULTISET join on the call's START LOCATION: every (key, value,
count) row of a side is folded into a sorted tuple per key, so a key that
carries several distinct shapes keeps all of them and a colliding key can never
be dropped by a last-writer dict.  A key present on only ONE side is scored
ONESIDED (uvm109's law: a pass that adds or removes objects must score
one-sided sets), never silently skipped.
"""
import sys
from collections import defaultdict


def load(p):
    d = defaultdict(list)
    if not p:
        return {}
    for l in open(p, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 3:
            continue
        d[f[1]].append((f[2], int(f[0])))
    return {k: tuple(sorted(v)) for k, v in d.items()}


g, pr = load(sys.argv[1]), load(sys.argv[2])
pa = load(sys.argv[3])
label = sys.argv[4]
keys = sorted(set(g) | set(pr) | set(pa))
c = defaultdict(int)
detail = []
for k in keys:
    gv, pv, av = g.get(k), pr.get(k), pa.get(k)
    if gv is None or pv is None:
        c['ONESIDED_PRIS'] += 1
        detail.append(('ONESIDED_PRIS', k, gv, pv, av))
        continue
    if not sys.argv[3]:
        if gv == pv:
            c['AGREE'] += 1
        else:
            c['DIFF'] += 1
            detail.append(('DIFF', k, gv, pv, av))
        continue
    if av is None:
        c['ONESIDED_PAT'] += 1
        detail.append(('ONESIDED_PAT', k, gv, pv, av))
        continue
    if pv == av:
        if gv == av:
            c['SAME_AGREE'] += 1
        else:
            c['SAME_DIFF'] += 1
            detail.append(('SAME_DIFF', k, gv, pv, av))
    elif gv == av:
        c['TOGOLD'] += 1
        detail.append(('TOGOLD', k, gv, pv, av))
    elif gv == pv:
        c['MOVEDWRONG'] += 1
        detail.append(('MOVEDWRONG', k, gv, pv, av))
    else:
        c['MOVEDOTHER'] += 1
        detail.append(('MOVEDOTHER', k, gv, pv, av))
print('%-28s %s' % (label, ' '.join('%s=%d' % kv for kv in sorted(c.items()))))


def show(v):
    return '<absent>' if v is None else ' ;; '.join('%dx %s' % (n, t)
                                                    for t, n in v)


for tag, k, gv, pv, av in detail:
    print('   %-13s @%s\n        golden=%s\n        pris  =%s%s'
          % (tag, k, show(gv), show(pv),
             ('\n        pat   =%s' % show(av)) if sys.argv[3] else ''))
