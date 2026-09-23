#!/usr/bin/env python3
"""r11u104 net-decl-assign cell lister: per LHS net NAME, the reading width
(parsed from the arm source), the RHS text, and golden | tag fields
(value, const type, size, decompile).  Keys on the NET NAME (the location key
is blind on rangeless golden constants), and a golden non-constant is NOFOLD.
usage: cells104.py <arm.sv> <golden.dump> <tag.dump> [<tag2.dump> ...]
"""
import re, sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from nda104 import read

def widths(sv):
    W = {}
    src = open(sv).read()
    for m in re.finditer(r'\b(wire|logic|bit)\s+(?:logic\s+)?(signed\s+|unsigned\s+)?'
                         r'(?:\[\s*(\d+)\s*:\s*(\d+)\s*\]\s*)?(\w+)\s*=\s*([^;]+);', src):
        w = abs(int(m.group(3)) - int(m.group(4))) + 1 if m.group(3) else 1
        W[m.group(5)] = (w, 's' if m.group(2) and m.group(2).startswith('s') else 'u',
                         ' '.join(m.group(6).split()))
    return W

def fmt(c):
    if c is None: return 'MISSING'
    if c['kind'] != 'constant': return c['kind']
    return f"{c['v']} ct{c['ct']} sz{c['sz']} d{c['d']}"

sv, gd, *tags = sys.argv[1:]
W = widths(sv)
g = read(gd); T = [read(t) for t in tags]
for n in sorted(g):
    w = W.get(n, ('?', '?', '?'))
    row = [fmt(g[n])] + [fmt(t.get(n)) for t in T]
    same = ['=' if r == row[0] else '#' for r in row[1:]]
    print(f"{n:10s} w{w[0]}{w[1]} {w[2]:22s} G[{row[0]}] " +
          ' '.join(f"{s}[{r}]" for s, r in zip(same, row[1:])))
