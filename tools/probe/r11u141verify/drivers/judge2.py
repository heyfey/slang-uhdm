#!/usr/bin/env python3
"""judge2.py <casekeydir> <P> <L> : alignment-robust record check. Aligns golden<->P and golden<->L with difflib on
(depth,type,name,defname); for every golden record aligned in BOTH, a field P matches (raw, fullname raw or canonical)
that L does not is WORSE2. Prints WORSE2 n [examples] | OK2 fixed=<n> (fields L matches that P did not)."""
import sys, os, difflib
wd,P,L=sys.argv[1:4]
N=['depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype','raw']
def rl(p): return [l.split('\t') for l in open(p).read().split('\n')[:-1]] if os.path.exists(p) else None
G=rl(f'{wd}/g_{P}.rec'); A=rl(f'{wd}/{P}.rec'); B=rl(f'{wd}/{L}.rec')
if not G or A is None or B is None: print('NA2'); sys.exit()
key=lambda r: tuple(r[:4])
def amap(X):
    sm=difflib.SequenceMatcher(None,[key(r) for r in G],[key(r) for r in X],autojunk=False)
    m={}
    for a,b,n in sm.get_matching_blocks():
        for k in range(n): m[a+k]=b+k
    return m
ma,mb=amap(A),amap(B)
def eq(g,x,k):
    if k==4: return g[4]==x[4] and (len(g)<15 or len(x)<15 or g[14]==x[14] or g[4].startswith('<in>'))
    return g[k]==x[k]
worse=[];fixed=0
for i,g in enumerate(G):
    if i in ma and i in mb:
        a=A[ma[i]]; b=B[mb[i]]
        for k in range(2,14):
            pa,pb=eq(g,a,k),eq(g,b,k)
            if pa and not pb: worse.append((i,N[k],g[k] if k!=4 else g[4]+'|'+(g[14] if len(g)>14 else ''),b[k] if k!=4 else b[4]+'|'+(b[14] if len(b)>14 else '')))
            elif pb and not pa: fixed+=1
print(('WORSE2 %d %s'%(len(worse),worse[:3])) if worse else f'OK2 fixed={fixed} unaligned_P={len(G)-len(ma)} unaligned_L={len(G)-len(mb)}')
