#!/usr/bin/env python3
# rdiff.py <casewd> : per-field counts golden vs pris / law, and the law's differing records (up to N)
import sys, difflib
F='depth type name defname fullname file line col endline endcol decompile size value consttype'.split()
w=sys.argv[1]; N=int(sys.argv[2]) if len(sys.argv)>2 else 8
def recs(p): return [l.rstrip('\n').split('\t') for l in open(p)]
G=recs(w+'/g.keep')
for t in ('pris','law'):
    O=recs(w+'/'+t+'.rec'); key=lambda r:'\t'.join(r[:4])
    sm=difflib.SequenceMatcher(None,[key(r) for r in G],[key(r) for r in O],autojunk=False)
    cnt={f:0 for f in F}; unp=len(G)+len(O); ex=[]
    for a,b,n in sm.get_matching_blocks():
        unp-=2*n
        for k in range(n):
            g,o=G[a+k],O[b+k]; d=[f for i,f in enumerate(F) if (g[i] if i<len(g) else '')!=(o[i] if i<len(o) else '')]
            for f in d: cnt[f]+=1
            if d and len(ex)<N: ex.append((d,g,o))
    print(t, ' '.join(f'{f}={v}' for f,v in cnt.items() if v), f'unpaired={unp}')
    if t=='law':
        for d,g,o in ex: print('  ',','.join(d),'| G:',' '.join(g[1:10]),'| O:',' '.join(o[1:10]))
