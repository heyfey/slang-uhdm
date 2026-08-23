#!/usr/bin/env python3
# r10earl76 — THE REGION TABLE.  Joins two cscen76 censuses (normalised by
# norm76.sh) on the site+route+span key and reports every cell whose OBJECT KIND
# differs, split by
#   HOME      gen scope (gd>=1) vs module body,
#   OWNER     always / initial / final / function / task / cont_assign / ...,
#   POSITION  the innermost loop marker on the route: for:i / for:c / for:n /
#             for:b / whl:c / whl:b / dow:c / dow:b / rpt:c / rpt:b / fe:b /
#             fv:b / if:c / cs:ci / (none).
# The kind is NOT part of the key (norm76.sh drops the leading letter), so a
# constant-vs-ref_obj flip is ONE cell, not two half-cells.
#   usage: region76.py <a.n> <b.n> [maxdetail]
import sys, re, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    for ln in open(p):
        k, _, pay = ln.rstrip('\n').partition(' ')
        d[k][pay] += 1
    return d

A, B = load(sys.argv[1]), load(sys.argv[2])
MX = int(sys.argv[3]) if len(sys.argv) > 3 else 8
POS = ('for:i', 'for:c', 'for:n', 'for:b', 'whl:c', 'whl:b', 'dow:c', 'dow:b',
       'rpt:c', 'rpt:b', 'fe:b', 'fv:b', 'ev:ec', 'if:c', 'ie:c', 'cs:c',
       'cs:ci')
OWN = ('always', 'initial', 'final', 'function', 'task', 'cont_assign',
       'param_assign', 'port_highconn')

def classify(k):
    gd = re.search(r'~gd=(\d+)~', k)
    home = 'GENSCOPE' if gd and int(gd.group(1)) > 0 else 'modbody'
    own = next((o for o in k.split('~') if o in OWN), '?')
    m = re.search(r'~(ST[^~]*)~', k)
    pos = '-'
    if m:
        segs = [s.split('[')[0] for s in m.group(1).split('/')]
        for s in reversed(segs):
            if s in POS:
                pos = s
                break
    return home, own, pos

tot = collections.Counter(); det = collections.defaultdict(list)
for k in set(A) | set(B):
    a, b = A.get(k, collections.Counter()), B.get(k, collections.Counter())
    ka = tuple(sorted({x.split()[0] for x in a}))
    kb = tuple(sorted({x.split()[0] for x in b}))
    if ka == kb: continue
    c = classify(k) + (ka, kb)
    tot[c] += 1; det[c].append((k, list(a), list(b)))
print('KIND-DIFFERING CELLS:', sum(tot.values()))
for c, n in sorted(tot.items(), key=lambda x: -x[1]):
    print(f"  {n:5d}  home={c[0]:8s} owner={c[1]:13s} pos={c[2]:6s}  A={c[3]} B={c[4]}")
    for k, a, b in det[c][:MX]:
        print('        ', k[-120:]); print('           A:', a[:2], '| B:', b[:2])
