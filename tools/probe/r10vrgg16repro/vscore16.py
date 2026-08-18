#!/usr/bin/env python3
"""r10vrgg16/vscore16.py — MULTISET join of three vcensus16 dumps.

usage: vscore16.py <golden.census> <base.census> <patched.census> [--rows]

Key   = (view, vpiFullName, vpiDefName).  Value = the MULTISET of payloads for
that key (a Counter, NOT a dict -- a last-writer dict silently drops rows and a
`sort -u` hides a multiplicity change, which is the exact shape of a
vector-size head).

Per slot:  STILL-RIGHT / FIXED (to golden) / BROKEN (away from golden) /
           STILL-WRONG (base==pat, both != golden) /
           CHANGED-WRONG (base != pat, both != golden)
"""
import sys, collections

def rd(p):
    d = collections.defaultdict(collections.Counter)
    with open(p) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln:
                continue
            parts = ln.split('\t')
            key = tuple(parts[:3])
            d[key][ '\t'.join(parts[3:]) ] += 1
    return d

g, b, p = rd(sys.argv[1]), rd(sys.argv[2]), rd(sys.argv[3])
rows = '--rows' in sys.argv
keys = sorted(set(g) | set(b) | set(p))
cnt = collections.Counter()
out = []
for k in keys:
    gv, bv, pv = g.get(k, collections.Counter()), b.get(k, collections.Counter()), p.get(k, collections.Counter())
    if bv == gv and pv == gv:
        cnt['STILL-RIGHT'] += 1
        continue
    if bv != gv and pv == gv:
        tag = 'FIXED'
    elif bv == gv and pv != gv:
        tag = 'BROKEN'
    elif bv == pv:
        tag = 'STILL-WRONG'
    else:
        tag = 'CHANGED-WRONG'
    cnt[tag] += 1
    out.append((tag, k, gv, bv, pv))
for t in ('BROKEN', 'CHANGED-WRONG', 'FIXED', 'STILL-WRONG'):
    print(f'{t} {cnt[t]}')
print(f'STILL-RIGHT {cnt["STILL-RIGHT"]}')
print(f'KEYS {len(keys)}  golden={len(g)} base={len(b)} pat={len(p)}')
if rows:
    for tag, k, gv, bv, pv in out:
        print(f'--- {tag} {k[0]} {k[1]} [{k[2]}]')
        for lbl, v in (('GOLD', gv), ('BASE', bv), ('PAT ', pv)):
            for pl, n in sorted(v.items()):
                print(f'    {lbl} x{n} {pl}')
