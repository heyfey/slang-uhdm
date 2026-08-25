#!/usr/bin/env python3
"""r10v124 verifier — score golden vs pristine vs patched.  Multiset join."""
import sys
from collections import defaultdict
def load(p):
    d = defaultdict(list)
    if not p: return {}
    try: f = open(p, errors='replace')
    except OSError: return {}
    for l in f:
        x = l.rstrip('\n').split('\t')
        if len(x) < 3: continue
        d[x[1]].append((x[2], int(x[0])))
    return {k: tuple(sorted(v)) for k,v in d.items()}
g, pr, pa = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
label = sys.argv[4]
keys = sorted(set(g)|set(pr)|set(pa))
c = defaultdict(int); det = []
for k in keys:
    gv, pv, av = g.get(k), pr.get(k), pa.get(k)
    if gv is None or pv is None:
        c['ONESIDED_PRIS'] += 1; det.append(('ONESIDED_PRIS',k,gv,pv,av)); continue
    if not sys.argv[3]:
        if gv == pv: c['AGREE'] += 1
        else: c['DIFF'] += 1; det.append(('DIFF',k,gv,pv,av))
        continue
    if av is None:
        c['ONESIDED_PAT'] += 1; det.append(('ONESIDED_PAT',k,gv,pv,av)); continue
    if pv == av:
        if gv == av: c['SAME_AGREE'] += 1
        else: c['SAME_DIFF'] += 1; det.append(('SAME_DIFF',k,gv,pv,av))
    elif gv == av: c['TOGOLD'] += 1; det.append(('TOGOLD',k,gv,pv,av))
    elif gv == pv: c['MOVEDWRONG'] += 1; det.append(('MOVEDWRONG',k,gv,pv,av))
    else: c['MOVEDOTHER'] += 1; det.append(('MOVEDOTHER',k,gv,pv,av))
print('%-30s %s' % (label, ' '.join('%s=%d' % kv for kv in sorted(c.items()))))
def sh(v): return '<absent>' if v is None else ' ;; '.join('%dx %s'%(n,t) for t,n in v)
for tag,k,gv,pv,av in det:
    print('   %-13s @%s\n      G=%s\n      P=%s\n      A=%s' % (tag,k,sh(gv),sh(pv),sh(av)))
