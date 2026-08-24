#!/usr/bin/env python3
"""r10v81 3-way multiset scorer.  golden / pristine / patched census files, one
row per cell, NO SPAN in the key or the payload.  Reports, per KEY (everything
left of '||') the multiset of payloads and classifies the pristine->patched
move: TO-GOLDEN, AWAY-GOLDEN, MOVED-WRONG (both wrong, different), STILL-WRONG,
STILL-RIGHT.  MEASUREMENT ONLY."""
import sys, collections, os
SETMODE = os.environ.get('SETMODE','1') == '1'
def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if '||' not in ln: continue
        k, v = ln.split('||', 1)
        import re
        k = re.sub(r' sp=\S+', '', k).strip()
        d[k][v.strip()] += 1
    return d
g, o, q = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
keys = set(g) | set(o) | set(q)
cnt = collections.Counter()
det = []
for k in sorted(keys):
    G, O, Q = g.get(k, collections.Counter()), o.get(k, collections.Counter()), q.get(k, collections.Counter())
    if SETMODE:
        G, O, Q = set(G), set(O), set(Q)
    if O == Q:
        cnt['STILL-RIGHT' if O == G else 'STILL-WRONG'] += 1
        continue
    if Q == G:   cls = 'TO-GOLDEN'
    elif O == G: cls = 'AWAY-GOLDEN'
    else:        cls = 'MOVED-WRONG'
    cnt[cls] += 1
    det.append((cls, k, sorted(G) if SETMODE else dict(G), sorted(O) if SETMODE else dict(O), sorted(Q) if SETMODE else dict(Q)))
for c in ('TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-WRONG','STILL-RIGHT'):
    print(f'{c:14s} {cnt[c]}')
print('---- moved cells ----')
for cls,k,G,O,Q in det:
    print(f'{cls} :: {k}\n   G={G}\n   O={O}\n   Q={Q}')
