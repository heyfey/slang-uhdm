import sys,re,collections
# multiset of (param_assign span, rhs op span, has typespec) in the uhdmtopModules section(s)
def cells(p):
    L=open(p,errors='replace').read().split('\n')
    out=collections.Counter(); sec=None
    for i,l in enumerate(L):
        if l.startswith('|uhdm'): sec=l
        if 'uhdmtopModules' not in (sec or ''): continue
        m=re.match(r'(\s*)\\_param_assign: , (line:\S+ endln:\S+)',l)
        if not m: continue
        ind=len(m.group(1))
        # find vpiRhs child
        for j in range(i+1,min(i+12,len(L))):
            if L[j].strip()=='|vpiRhs:':
                r=re.match(r'(\s*)\\_(\w+): .*?(line:\S+ endln:\S+)?$',L[j+1])
                kind=r.group(2) if r else '?'; rind=len(r.group(1)) if r else 0
                has=False
                for k in range(j+2,min(j+10,len(L))):
                    s=L[k]; ci=len(s)-len(s.lstrip())
                    if ci<=rind: break
                    if ci==rind+2 and s.strip()=='|vpiTypespec:': has=True
                out[(m.group(2),kind,L[j+1].split(', ',1)[-1].strip(),has)]+=1
                break
    return out
arm=sys.argv[1]
g=cells(f'{arm}/gold.dump'); p=cells(f'{arm}/pris.dump'); w=cells(f'{arm}/lawx.dump')
for k in sorted(set(p)|set(w)):
    if p[k]!=w[k]:
        alt=(k[0],k[1],k[2],not k[3])
        print(arm,k,'pris',p[k],'law',w[k],'gold',g[k],'gold_alt',g[alt])
