#!/usr/bin/env python3
"""r10earl73 — the SECOND stage of the mover prediction: over a pair of
pacen73 censuses, count only the shared cells whose (vpiConstType, value TAG)
DISAGREE.  predict73.sh is a deliberate over-approximation (its line diff also
catches parent-chain and VpiOverriden differences); this is the keyed multiset
join that says whether the law can actually reach the database.
MEASUREMENT ONLY.  usage: ctdiff73.py <golden.pa> <ours.pa>"""
import sys, collections, re
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        if f[0] != 'PA': continue
        d[(f[1], f[2])].append(' '.join(f[3:]))
    for k in d: d[k].sort()
    return d
G, O = load(sys.argv[1]), load(sys.argv[2])
def ct(p):
    m = re.search(r'ct=(\d+)', p); return m.group(1) if m else '-'
def tag(p):
    m = re.search(r'val=([A-Z]+):', p); return m.group(1) if m else '-'
def ovr(p):
    m = re.search(r'ovr=(\d)', p); return m.group(1) if m else '-'
c = collections.Counter()
for k in G:
    if k not in O: continue
    g, o = G[k], O[k]
    for i in range(min(len(g), len(o))):
        if ct(g[i]) != ct(o[i]) or tag(g[i]) != tag(o[i]):
            c[(ovr(g[i]), ct(g[i])+'/'+tag(g[i]), ct(o[i])+'/'+tag(o[i]))] += 1
tot = sum(c.values())
print('CT/TAG-differing shared cells:', tot)
for k, n in c.most_common(): print('  ovr=%s golden %-10s ours %-10s x%d' % (k[0], k[1], k[2], n))
