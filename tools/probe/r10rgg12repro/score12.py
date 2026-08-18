#!/usr/bin/env python3
"""r10rgg12/score12.py -- score a censused grid: golden vs ours, per cell.

  usage: score12.py <goldencen> <ourscen> [<patchedcen>] [--rows]

Two-file form prints SAME/DIFF per cell.  Three-file form classifies every
census row OK / FIXED / BROKEN / STILL, which is the only form that can show a
patch moved a row AWAY from golden.
"""
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for l in open(p, errors='replace'):
        parts = l.rstrip('\n').split('\t')
        if len(parts) < 3: continue
        d[(parts[0], parts[1])].append(parts[2])
    return {k: sorted(v) for k, v in d.items()}
g = load(sys.argv[1]); o = load(sys.argv[2])
p = load(sys.argv[3]) if len(sys.argv) > 3 and not sys.argv[3].startswith('--') else None
rows = '--rows' in sys.argv
if p is None:
    per = collections.Counter()
    for k in set(g) | set(o):
        per[(k[0], 'SAME' if g.get(k) == o.get(k) else 'DIFF')] += 1
    cells = sorted({k[0] for k in set(g) | set(o)})
    for c in cells:
        print('%-32s SAME=%-5d DIFF=%d' % (c, per[(c, 'SAME')], per[(c, 'DIFF')]))
    print('-- cells=%d SAME=%d DIFF=%d' % (len(cells),
          sum(per[(c, 'SAME')] for c in cells), sum(per[(c, 'DIFF')] for c in cells)))
else:
    cnt = collections.Counter(); ex = collections.defaultdict(list)
    for k in set(g) | set(o) | set(p):
        G, B, P = g.get(k), o.get(k), p.get(k)
        if B == P:
            cnt['OK' if B == G else 'STILL'] += 1
        elif B != G and P == G:
            cnt['FIXED'] += 1; ex['FIXED'].append(k)
        elif B == G and P != G:
            cnt['BROKEN'] += 1; ex['BROKEN'].append(k)
        else:
            cnt['MOVED-STILL-WRONG'] += 1; ex['MOVED-STILL-WRONG'].append(k)
    for k in ('OK', 'FIXED', 'BROKEN', 'STILL', 'MOVED-STILL-WRONG'):
        print('%-18s %d' % (k, cnt[k]))
    if rows:
        for kind in ('FIXED', 'BROKEN', 'MOVED-STILL-WRONG'):
            for k in sorted(ex[kind]):
                print(kind, k[0], k[1])
