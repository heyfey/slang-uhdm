import re,sys
def read(p):
    L=open(p,errors='replace').read().split('\n')
    res={}
    for i,l in enumerate(L):
        if 'vpiNetDeclAssign:1' not in l: continue
        blk='\n'.join(L[i:i+40])
        m=re.search(r'\|vpiRhs:\s*\n\s*\\_constant:[^\n]*\n(.*?)\|vpiLhs:\s*\n\s*\\_logic_net: \(([^)]*)\)',blk,re.S)
        if not m: continue
        c=m.group(1); n=m.group(2).split('.')[-1]
        d=re.search(r'\|vpiDecompile:([^\n]*)',c); s=re.search(r'\|vpiSize:(\d+)',c)
        v=re.search(r'\|((?:INT|UINT|HEX|BIN|DEC|OCT|REAL|STRING):[^\n]*)',c); t=re.search(r'\|vpiConstType:(\d+)',c)
        res[n]=(v.group(1) if v else '?', 'ct'+(t.group(1) if t else '?'), 'sz'+(s.group(1) if s else '?'), 'd='+(d.group(1) if d else '?'))
    return res
g=read(sys.argv[1]); a=read(sys.argv[2]); b=read(sys.argv[3])
to=away=0
for n in g:
    G=g[n]; A=a.get(n); B=b.get(n)
    flag=''
    if A==G and B!=G: flag=' <<<< AWAY'; away+=1
    if A!=G and B==G: flag=' <<<< TO'; to+=1
    print(f"{n:6s} G={' '.join(G):32s} PRIS={' '.join(A) if A else 'MISSING':32s} LAW={' '.join(B) if B else 'MISSING':32s}{flag}")
print(f"TO={to} AWAY={away}")
