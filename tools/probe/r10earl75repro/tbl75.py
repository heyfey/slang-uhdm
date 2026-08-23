#!/usr/bin/env python3
# r10earl75 — GOLDEN TABLE / 3-way FIELD-SPLIT report for one grid arm.
# MEASUREMENT ONLY.  usage: tbl75.py <gold.n> <pris.n> <patc.n>
#
# Two scores are printed, because they answer different questions:
#   TS     — the ref_typespec fields ONLY (ts kind / name / defname / sign).
#            This law adds a ref_typespec EDGE and nothing else, so this is the
#            score that adjudicates it.
#   VALUE  — vpiConstType / VpiSize / VpiValue / VpiDecompile.  This law must
#            leave every one of them untouched; any movement here is a bug.
# A cell golden does not have AT ALL (`<none>`) is counted apart, because it is
# neither TO-GOLDEN nor AWAY-GOLDEN — there is nothing to move toward.
import sys
from collections import defaultdict, Counter
NK = 9
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:NK])].append(' '.join(f[NK:]))
    return d
TSF = ('ts=', 'tsname=', 'tsdef=', 'tssgn=')
VAF = ('ct=', 'sz=', 'val=', 'dec=')
def proj(p, keys):
    if p == '<none>': return '<none>'
    return ' '.join(t for t in p.split() if t.startswith(keys))
g, o, q = (load(a) for a in sys.argv[1:4])
def score(keys, label):
    b = Counter(); ex = defaultdict(list)
    for k in set(g) | set(o) | set(q):
        G, O, Q = sorted(g.get(k, [])), sorted(o.get(k, [])), sorted(q.get(k, []))
        n = max(len(G), len(O), len(Q))
        G += ['<none>']*(n-len(G)); O += ['<none>']*(n-len(O)); Q += ['<none>']*(n-len(Q))
        for i in range(n):
            gd, pr, pa = proj(G[i], keys), proj(O[i], keys), proj(Q[i], keys)
            if G[i] == '<none>':
                b['NO-GOLDEN-CELL' + ('(moved)' if pr != pa else '')] += 1
                if pr != pa: ex['NO-GOLDEN-CELL(moved)'].append((k, gd, pr, pa))
                continue
            if Q[i] == '<none>':
                b['NO-OUR-CELL'] += 1; continue
            if pr == pa:
                b['STILL-RIGHT' if pa == gd else 'STILL-WRONG'] += 1
                if pa != gd: ex['STILL-WRONG'].append((k, gd, pr, pa))
                continue
            if pa == gd: b['TO-GOLDEN'] += 1; ex['TO-GOLDEN'].append((k, gd, pr, pa))
            elif pr == gd: b['AWAY-GOLDEN'] += 1; ex['AWAY-GOLDEN'].append((k, gd, pr, pa))
            else: b['MOVED-WRONG'] += 1; ex['MOVED-WRONG'].append((k, gd, pr, pa))
    print(label, dict(b))
    return ex
exts = score(TSF, 'TS   ')
exv  = score(VAF, 'VALUE')
for t in ('AWAY-GOLDEN', 'MOVED-WRONG'):
    seen = set()
    for k, gd, pr, pa in exts[t] + exv[t]:
        s = (k.split(' ')[3], k.split(' ')[4], k.split(' ')[8], gd, pr, pa)
        if s in seen: continue
        seen.add(s)
        print(' ', t, k.split(' ')[3], k.split(' ')[4], k.split(' ')[8],
              '| G', gd, '| pris', pr, '| patc', pa)
