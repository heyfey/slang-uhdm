#!/usr/bin/env python3
"""r11u32 — per-signal DEF-view vpiTypespec presence, golden vs ours.
Indentation rule as in gridread.py: an object at indent I owns the `|field:`
lines at indent I+2.  Only the OUTERMOST sighting of each wanted leaf counts.
usage: tsread.py <golden.raw> <ours.raw> <leaf-prefix>
"""
import re, sys

OBJ = re.compile(r'^(\s*)\\?_?([a-z_0-9]+): \(([^)]*)\)')

def sec(p):
    L = open(p, errors='replace').read().split('\n')
    d = e = t = None
    for i, l in enumerate(L):
        s = l.strip()
        if s == '|uhdmallModules:' and d is None: d = i
        elif s == '|uhdmtopModules:' and e is None: e = i
        elif s.startswith('\\_weaklyReferenced:') and t is None: t = i
    n = len(L)
    return L[(d or 0):(e or n)], L[(e or n):(t or n)]

def scan(L, pfx):
    out = {}
    for i, l in enumerate(L):
        m = OBJ.match(l)
        if not m:
            continue
        leaf = m.group(3).split('.')[-1]
        if not leaf.startswith(pfx) or leaf in out:
            continue
        ind = len(m.group(1))
        has = False
        for l2 in L[i + 1:]:
            m2 = re.match(r'^(\s*)[|\\]', l2)
            if not m2 or len(m2.group(1)) <= ind:
                break
            m3 = re.match(r'^(\s*)\|(\w+):', l2)
            if m3 and len(m3.group(1)) == ind + 2 and m3.group(2) == 'vpiTypespec':
                has = True
        out[leaf] = (m.group(2), has)
    return out

def main():
    g, o, pfx = sys.argv[1], sys.argv[2], sys.argv[3]
    gd, _ = sec(g); od, _ = sec(o)
    G, O = scan(gd, pfx), scan(od, pfx)
    print(f'{"SIGNAL":22s} | {"DEF golden":26s} | {"DEF ours":26s} | VERDICT')
    n = 0
    for k in sorted(set(G) | set(O)):
        a = G.get(k, ('-', False)); b = O.get(k, ('-', False))
        v = '' if a == b else 'DIFF'
        n += bool(v)
        fa = f'{a[0]} ts={"YES" if a[1] else "no"}'
        fb = f'{b[0]} ts={"YES" if b[1] else "no"}'
        print(f'{k:22s} | {fa:26s} | {fb:26s} | {v}')
    print(f'-- signals: {len(set(G) | set(O))}   DIFF: {n}')

main()
