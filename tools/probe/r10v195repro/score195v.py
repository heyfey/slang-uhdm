#!/usr/bin/env python3
"""r10v195 — the VERIFIER's scorer.  Same multiset join as the implementer's
score195.py but MOVED-WRONG is reported SEPARATELY from STILL-WRONG: the
implementer's tool prints them merged ("MOVED/STILL-WRONG n"), so a slot where
pristine was wrong one way and the patch made it wrong a DIFFERENT way would
not show up in the printed summary at all.  MEASUREMENT ONLY.

  score195v.py <golden.cen> <pristine.cen> <patched.cen> [--only=S] [--show]
"""
import sys, collections

def load(path):
    m = collections.Counter()
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln.startswith('LIST|'):
                continue
            m[ln.split('|', 2)[2]] += 1
    return m

def bykey(cnt):
    d = collections.defaultdict(collections.Counter)
    for row, n in cnt.items():
        d[row.rsplit('|', 1)[0]][row.rsplit('|', 1)[1]] += n
    return d

args = [a for a in sys.argv[1:] if not a.startswith('--')]
opts = [a for a in sys.argv[1:] if a.startswith('--')]
only = next((o.split('=',1)[1] for o in opts if o.startswith('--only=')), None)
show = '--show' in opts
g, a, b = (bykey(load(p)) for p in args[:3])
keys = set(g) | set(a) | set(b)
if only:
    keys = {k for k in keys if only in k}
to_g = away = moved = still = agree = 0
for k in sorted(keys):
    gv = g.get(k, collections.Counter()); av = a.get(k, collections.Counter()); bv = b.get(k, collections.Counter())
    po, qo = (av == gv), (bv == gv)
    if po and qo:
        agree += 1; continue
    if not po and qo:
        to_g += 1; tag = 'TO-GOLDEN'
    elif po and not qo:
        away += 1; tag = 'AWAY-GOLDEN'
    elif av != bv:
        moved += 1; tag = 'MOVED-WRONG'
    else:
        still += 1; tag = 'STILL-WRONG'
    if show and tag in ('TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG'):
        print(f'{tag} {k}\n    golden={dict(gv)}\n    pris  ={dict(av)}\n    pat   ={dict(bv)}')
print(f'TO-GOLDEN {to_g}  AWAY-GOLDEN {away}  MOVED-WRONG {moved}  STILL-WRONG {still}  AGREE {agree}  KEYS {len(keys)}')
