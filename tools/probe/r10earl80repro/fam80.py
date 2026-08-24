#!/usr/bin/env python3
"""r10earl80 — split the differing param_assign cells of a MULTISET join into
FAMILIES by which judge-read field disagrees, and print each family's shapes.

MEASUREMENT ONLY.  Multiset join (RESUME §9: keys collide; a last-writer dict
drops rows).  The payload carries no span.

usage: fam80.py <golden.pa> <ours.pa> [--shapes N]
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        if not ln.startswith('PA '):
            continue
        f = ln.rstrip('\n').split(' ')
        d[(f[1], f[2])].append(' '.join(f[3:]))
    for k in d: d[k].sort()
    return d

def fields(s):
    return dict(x.split('=', 1) for x in s.split() if '=' in x)

def famname(gd, od):
    dif = sorted(f for f in set(gd) | set(od) if gd.get(f) != od.get(f))
    if dif == ['dec']:
        gw = gd['dec'].split("'")[0] if "'" in gd['dec'] else None
        ow = od['dec'].split("'")[0] if "'" in od['dec'] else None
        if gw is not None and ow is not None and \
           gd['dec'].split("'")[1:] == od['dec'].split("'")[1:]:
            return 'DECOMPILE-WIDTH'
        return 'DECOMPILE-OTHER'
    if 'sz' in dif and len(dif) == 1: return 'SIZE'
    if set(dif) <= {'ct', 'val', 'dec'}: return 'VALUE-TAG'
    if set(dif) <= {'ts', 'tssgn', 'lts', 'lsgn'}: return 'TYPESPEC'
    return 'MIXED(' + ','.join(dif) + ')'

def main():
    G, O = load(sys.argv[1]), load(sys.argv[2])
    nsh = 6
    if '--shapes' in sys.argv: nsh = int(sys.argv[sys.argv.index('--shapes')+1])
    fams = collections.Counter()
    ex = collections.defaultdict(collections.Counter)
    for k in sorted(set(G) | set(O)):
        g, o = G.get(k, []), O.get(k, [])
        for i in range(min(len(g), len(o))):
            if g[i] == o[i]: continue
            f = famname(fields(g[i]), fields(o[i]))
            fams[f] += 1
            ex[f][(k[1], g[i], o[i])] += 1
    print("FAMILIES of the differing param_assign cells:")
    for f, n in fams.most_common():
        print("  %-28s %d" % (f, n))
    for f, n in fams.most_common():
        print("\n-- %s (%d cells) --" % (f, n))
        for (nm, gi, oi), c in ex[f].most_common(nsh):
            print("  x%-4d %s\n    G: %s\n    O: %s" % (c, nm, gi, oi))

main()
