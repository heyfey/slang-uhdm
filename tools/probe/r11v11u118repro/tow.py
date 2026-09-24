import sys, collections
G,P,L=[collections.Counter(open(f,errors='replace').read().splitlines()) for f in sys.argv[1:4]]
rem=P-L; add=L-P
tow=away=side=0; aw=[]
for l,c in add.items():   # lines the law adds
    # toward if golden has more of this line than pristine did
    need=max(0,G[l]-P[l]); t=min(c,need); tow+=t
    if c-t: away+=c-t; aw.append(('ADD',l,c-t,G[l]))
for l,c in rem.items():   # lines the law removes
    excess=max(0,P[l]-G[l]); t=min(c,excess); tow+=t
    if c-t: away+=c-t; aw.append(('DEL',l,c-t,G[l]))
print(f'changed={sum(add.values())+sum(rem.values())} toward={tow} away={away}')
for a in aw[:40]: print(a)
