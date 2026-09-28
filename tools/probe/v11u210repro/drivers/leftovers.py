#!/usr/bin/env python3
"""v11u210: object-aware census of the struct-typespec member LEFTOVERS (typespec_member -> vpiExpr -> constant) in
three uhdm-dumps (golden, pristine, law): each leftover keyed by (member name, location, value) as a multiset.
LOST = golden-and-pristine keys the law no longer writes; GAINED = golden-and-law keys pristine did not write.
usage: leftovers.py <g.dump> <pris.dump> <law.dump>"""
import re, sys
from collections import Counter
def load(p):
    L = open(p, errors='replace').read().split('\n'); c = Counter(); mem = None
    for i, l in enumerate(L):
        m = re.search(r'\\_typespec_member: \((\w+)\)', l)
        if m: mem = m.group(1); continue
        if l.strip() == '|vpiExpr:' and mem and i + 1 < len(L):
            m2 = re.search(r'\\_constant: ?(.*)$', L[i + 1])
            if not m2: continue
            loc = re.sub(r'id:\d+,? ?', '', m2.group(1)).strip(', ')
            val = ''
            for k in range(i + 2, min(i + 12, len(L))):
                v = re.search(r'\|((?:U?INT|DEC|BIN|HEX|OCT|STRING|REAL):.*)$', L[k])
                if v: val = v.group(1); break
                if '\\_' in L[k] and 'vpiParent' not in L[k - 1]: break
            c[(mem, loc, val)] += 1
    return c
g, p, l = (load(x) for x in sys.argv[1:4])
lost = Counter({k: min(g[k], p[k]) - min(g[k], l[k]) for k in p if min(g[k], p[k]) > min(g[k], l[k])})
gained = Counter({k: min(g[k], l[k]) - min(g[k], p[k]) for k in l if min(g[k], l[k]) > min(g[k], p[k])})
print(f"leftovers golden={sum(g.values())} pris={sum(p.values())} law={sum(l.values())} lost={sum(lost.values())} gained={sum(gained.values())}")
for k, v in lost.items(): print('  LOST', v, k)
