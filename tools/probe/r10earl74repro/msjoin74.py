#!/usr/bin/env python3
"""r10earl74 — MULTISET join of two pacen73 censuses.

MEASUREMENT ONLY.  Keys collide by design (one span per gen unrolling), so the
join is a MULTISET join (RESUME §9: a last-writer dict drops rows).

usage: msjoin74.py <golden.pa> <ours.pa> [--base <base.pa>]
  With --base, each shared key is scored 3-way:
    TO-GOLDEN   base != golden, ours == golden
    AWAY-GOLDEN base == golden, ours != golden
    MOVED-WRONG base != golden, ours != golden, ours != base
    STILL-WRONG base != golden, ours == base
    STILL-RIGHT base == golden, ours == golden
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln.startswith('PA '):
            continue
        f = ln.split(' ')
        # PA <chain> <name> ovr= lts= lsgn= lsz= || <rest...>
        key = (f[1], f[2])
        pay = ' '.join(f[3:])
        d[key].append(pay)
    for k in d:
        d[k].sort()
    return d

def main():
    a = sys.argv
    base = None
    if '--base' in a:
        i = a.index('--base'); base = load(a[i+1]); del a[i:i+2]
    G, O = load(a[1]), load(a[2])
    ks = set(G) | set(O)
    shared = diff = gonly = oonly = 0
    cnt = collections.Counter()
    shapes = collections.Counter()
    for k in sorted(ks):
        g, o = G.get(k, []), O.get(k, [])
        n = min(len(g), len(o))
        gonly += max(0, len(g) - n); oonly += max(0, len(o) - n)
        b = base.get(k, []) if base is not None else None
        for i in range(n):
            shared += 1
            gi, oi = g[i], o[i]
            bi = b[i] if b is not None and i < len(b) else None
            if gi != oi:
                diff += 1
                shapes[(gi, oi)] += 1
            if base is not None:
                if bi == gi and oi == gi: cnt['STILL-RIGHT'] += 1
                elif bi != gi and oi == gi: cnt['TO-GOLDEN'] += 1
                elif bi == gi and oi != gi: cnt['AWAY-GOLDEN'] += 1
                elif bi is not None and oi == bi: cnt['STILL-WRONG'] += 1
                else: cnt['MOVED-WRONG'] += 1
    print(f"keys G={len(G)} O={len(O)} shared_cells={shared} DIFFERING={diff} "
          f"gold_only={gonly} ours_only={oonly}")
    if base is not None:
        for k in ('STILL-RIGHT','TO-GOLDEN','AWAY-GOLDEN','MOVED-WRONG','STILL-WRONG'):
            print(f"  {k}: {cnt[k]}")
    for (gi, oi), n in shapes.most_common(40):
        print(f"--- x{n}\n  G: {gi}\n  O: {oi}")

main()
