#!/usr/bin/env python3
"""r10uvm97 — MULTISET join of two ct97cen censuses.  MEASUREMENT ONLY.

LHS is ALWAYS golden.  Key = (SITE, OWNER, NAME, KIND) — never the ID (ids
differ per side and per run) and never the SPAN (golden and we legitimately
locate a shared class typedef object at different declarations, and no
generated Compare reads a span).  Value = the JUDGED shape: whether the
typespec carries a Typedef_alias, its Class_defn target and its Instance.

A dict-keyed join would DROP the DEF/ELAB/import copies that share a key, so
both sides are multisets and the comparison is `sorted(list) == sorted(list)`.
"""
import sys, collections

def load(p):
    d = collections.defaultdict(list)
    try:
        f = open(p)
    except OSError:
        return d
    for l in f:
        l = l.rstrip('\n')
        if not l:
            continue
        c = l.split('\t')
        if len(c) < 9:
            continue
        d['|'.join((c[0], c[2], c[3], c[4]))].append(
            ('ALIAS' if c[6] != '-' else 'NOALIAS', c[7], c[8]))
    return d

name, gp, op = sys.argv[1], sys.argv[2], sys.argv[3]
G, O = load(gp), load(op)
same = diff = 0
detail = []
for k in sorted(set(G) | set(O)):
    g, o = sorted(G.get(k, [])), sorted(O.get(k, []))
    if g == o:
        same += 1
    else:
        diff += 1
        detail.append('    %s\n        G=%s\n        O=%s' % (k, g, o))
print('%-40s same %5d  DIFF %4d' % (name, same, diff))
for d in detail:
    print(d)
