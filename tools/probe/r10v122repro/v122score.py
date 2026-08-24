#!/usr/bin/env python3
"""r10v122 (verifier) - score golden vs pristine vs patched, COMPARE-VISIBLE
payload (actual kind + name).  MULTISET JOIN: several census rows can share the
(ref kind, ref name, ref span) key with DIFFERENT actuals, so the value is the
sorted MULTISET of (count, payload) - a last-writer dict would silently drop
one of them (RESUME s9 census trap).
  v122score.py <g.cells> <pris.cells> <pat.cells|''> <label>
"""
import sys
from collections import Counter, defaultdict


def load(p):
    d = defaultdict(Counter)
    if not p:
        return {}
    for l in open(p, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 5:
            continue
        d[(f[1], f[2], f[3])][f[4]] += int(f[0])
    return {k: tuple(sorted(v.items())) for k, v in d.items()}


def show(v):
    return '<absent>' if v is None else ' + '.join('%dx %s' % (c, p) for p, c in v)


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
    if not sys.argv[3]:
        c['AGREE' if gv == pv else 'DIFF'] += 1
        if gv != pv:
            detail.append(('DIFF', k, gv, pv, av))
        continue
    if av is None:
        c['ONESIDED_PAT'] += 1
        detail.append(('ONESIDED_PAT', k, gv, pv, av))
        continue
    agree_p, agree_a = (gv == pv), (gv == av)
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
print('%-30s %s' % (label, ' '.join('%s=%d' % kv for kv in sorted(c.items()))))
for tag, k, gv, pv, av in detail:
    print('   %-13s %s %s %s' % (tag, k[0], k[1], k[2]))
    print('        golden=%s' % show(gv))
    print('        pris  =%s' % show(pv))
    if sys.argv[3]:
        print('        pat   =%s' % show(av))
