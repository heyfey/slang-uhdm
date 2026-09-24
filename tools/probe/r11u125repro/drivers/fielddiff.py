#!/usr/bin/env python3
# fielddiff.py g.rec o.rec : per-field differing object counts (index-paired when keys align via diff)
import sys, subprocess
F='depth type name defname fullname file line col endline endcol decompile size value consttype'.split()
def recs(p): return [l.rstrip('\n').split('\t') for l in open(p)]
G, O = recs(sys.argv[1]), recs(sys.argv[2])
key = lambda r: '\t'.join(r[:4])
import difflib
sm = difflib.SequenceMatcher(None, [key(r) for r in G], [key(r) for r in O], autojunk=False)
cnt = {f: 0 for f in F}; unp = len(G) + len(O)
for a, b, n in sm.get_matching_blocks():
    unp -= 2 * n
    for k in range(n):
        g, o = G[a + k], O[b + k]
        for i, f in enumerate(F):
            if (g[i] if i < len(g) else '') != (o[i] if i < len(o) else ''): cnt[f] += 1
print(' '.join(f'{f}={v}' for f, v in cnt.items() if v), f'unpaired={unp}')
