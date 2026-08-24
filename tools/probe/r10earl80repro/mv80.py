#!/usr/bin/env python3
"""r10earl80 — SCORE a mover arm AGAINST GOLDEN, cell by cell (the MOVER RULE:
a mover is a ROW, and a row is scored against golden, never merely counted).

usage: mv80.py <golden.pa> <base.pa> <patched.pa>
"""
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('PA '): continue
        f = ln.rstrip('\n').split(' ')
        d[(f[1], f[2])].append(' '.join(f[3:]))
    for k in d: d[k].sort()
    return d
G, B, P = (load(a) for a in sys.argv[1:4])
c = collections.Counter(); rows = []
for k in sorted(set(G) | set(B) | set(P)):
    g, b, p = G.get(k, []), B.get(k, []), P.get(k, [])
    for i in range(min(len(g), len(b), len(p))):
        if b[i] == p[i]:
            c['UNCHANGED-EQ' if g[i] == b[i] else 'UNCHANGED-NE'] += 1
            continue
        if p[i] == g[i]: v = 'TO-GOLDEN'
        elif b[i] == g[i]: v = 'AWAY-GOLDEN'
        else: v = 'MOVED-WRONG'
        c[v] += 1
        rows.append((v, k[1], k[0], g[i], b[i], p[i]))
print("  ".join("%s=%d" % (x, c[x]) for x in
      ('UNCHANGED-EQ','UNCHANGED-NE','TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG')))
for v, nm, ch, g, b, p in rows:
    print("\n%-12s %s   %s\n  G: %s\n  B: %s\n  P: %s" % (v, nm, ch, g, b, p))
