#!/usr/bin/env python3
"""r10v80 — generic 3-way cell scorer.  MEASUREMENT ONLY.
usage: vsc80.py <golden.pa> <base.pa> <patched.pa> [--rows N] [--typespec]
Key = (VpiParent chain, Lhs name); payload = the judge-read constant fields
(ct/size/value/decompile/typespec-kind/typespec-signedness) + param_assign
VpiOverriden + the Lhs declared typespec.  NO span in the judge payload; span
PRESENCE is joined and scored on its own axis.  Multiset join (RESUME §9).
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('PA '):
            continue
        f = ln.rstrip('\n').split(' ')
        span = ''
        if f[-1].startswith('SPAN='):
            span = f[-1]; f = f[:-1]
        pay = ' '.join(f[3:])
        d[(f[1], f[2])].append((pay, span))
    for k in d:
        d[k].sort()
    return d

G, B, P = (load(a) for a in sys.argv[1:4])
nrows = 12
if '--rows' in sys.argv:
    nrows = int(sys.argv[sys.argv.index('--rows') + 1])
c = collections.Counter(); sc = collections.Counter(); rows = []
allk = sorted(set(G) | set(B) | set(P))
for k in allk:
    g, b, p = G.get(k, []), B.get(k, []), P.get(k, [])
    c['KEY-MISSING-GOLDEN'] += (1 if not g and (b or p) else 0)
    c['KEY-MISSING-OURS'] += (1 if g and not p else 0)
    if len(b) != len(p):
        c['ARITY-CHANGED'] += 1
    n = min(len(g), len(b), len(p))
    c['CELLS'] += n
    for i in range(n):
        gp, bp, pp = g[i][0], b[i][0], p[i][0]
        if bp == pp:
            c['UNCHANGED-EQ' if gp == bp else 'UNCHANGED-NE'] += 1
        else:
            if pp == gp: v = 'TO-GOLDEN'
            elif bp == gp: v = 'AWAY-GOLDEN'
            else: v = 'MOVED-WRONG'
            c[v] += 1
            rows.append((v, k[1], k[0], gp, bp, pp))
        gs, bs, ps = g[i][1], b[i][1], p[i][1]
        if bs == ps:
            sc['SPAN-UNCHANGED-EQ' if gs == bs else 'SPAN-UNCHANGED-NE'] += 1
        elif ps == gs: sc['SPAN-TO-GOLDEN'] += 1
        elif bs == gs: sc['SPAN-AWAY-GOLDEN'] += 1
        else: sc['SPAN-MOVED-WRONG'] += 1
print("  ".join("%s=%d" % (x, c[x]) for x in
      ('CELLS','UNCHANGED-EQ','UNCHANGED-NE','TO-GOLDEN','AWAY-GOLDEN',
       'MOVED-WRONG','ARITY-CHANGED','KEY-MISSING-GOLDEN','KEY-MISSING-OURS')))
print("  ".join("%s=%d" % (x, sc[x]) for x in
      ('SPAN-UNCHANGED-EQ','SPAN-UNCHANGED-NE','SPAN-TO-GOLDEN',
       'SPAN-AWAY-GOLDEN','SPAN-MOVED-WRONG')))
bad = [r for r in rows if r[0] != 'TO-GOLDEN']
for v, nm, ch, g_, b_, p_ in (bad + rows)[:nrows]:
    print("\n%-12s %s   %s\n  G: %s\n  B: %s\n  P: %s" % (v, nm, ch, g_, b_, p_))
