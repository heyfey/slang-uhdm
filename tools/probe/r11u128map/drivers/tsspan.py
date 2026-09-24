#!/usr/bin/env python3
"""Span/file facets on NAMED typespecs, by stability: for a named typespec
(type,name), golden's distinct (file,span) values across all its listings
vs ours. STABLE: golden one span; USE-SITE: golden more spans than ours
(golden's per-use copies carry use-site spans: a copy per use is needed);
USE-SITE-BOTH: ours at least as many. Unnamed typespecs are UNNAMED (not
classified). Writes <work>/tsspan_<src>.json: row -> golden indices of
USE-SITE objects. Args: <work> <corpus|probe> <dump root>"""
import json, sys, collections, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from analyze import load
W, src, root = sys.argv[1:4]
cls = collections.Counter(); byc = collections.defaultdict(collections.Counter); rows = collections.defaultdict(set)
out = {}
for l in open(f'{W}/{src}.jsonl'):
    r = json.loads(l)
    xs = [x for x in r['rows'] if x['facet'] in ('span', 'file') and x['type'].endswith('_typespec')]
    if not xs: continue
    D = f"{root}/{r['corpus']}/{r['mode']}/{r['test']}"
    A, B = load(D + '.a'), load(D + '.b')
    def spans(S):
        m = collections.defaultdict(set)
        for q in S:
            if q[1].endswith('_typespec') and q[2]: m[(q[1], q[2])].add((q[5],) + tuple(q[6:10]))
        return m
    sa, sb = spans(A), spans(B)
    key = '|'.join((r['corpus'], r['mode'], r['test']))
    for x in xs:
        a = A[x['ia']]; k = (a[1], a[2])
        if not a[2]: c = 'UNNAMED'
        else:
            g, o = len(sa[k]), len(sb[k])
            c = 'STABLE' if g == 1 else ('USE-SITE' if o < g else 'USE-SITE-BOTH')
        cls[c] += 1; byc[x['cluster']][c] += 1; rows[c].add(key)
        if c == 'USE-SITE': out.setdefault(key, []).append(x['ia'])
json.dump(out, open(f'{W}/tsspan_{src}.json', 'w'))
print('objects:', dict(cls), ' row-modes touched:', {k: len(v) for k, v in rows.items()})
for c, v in sorted(byc.items(), key=lambda kv: -sum(kv[1].values()))[:30]: print(dict(v), c)
