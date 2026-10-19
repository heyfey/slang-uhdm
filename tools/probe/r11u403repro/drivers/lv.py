import sys,re
def lv(f):
    L=open(f).read().split('\n'); out={}
    for i,l in enumerate(L):
        if l.strip()=='|vpiLoopVars:':
            m=re.match(r'\s*\\_(\w+): \(([^)]*)\), line:(\d+:\d+)',L[i+1])
            if m:
                ts=''
                for j in range(i+2,i+12):
                    if 'vpiActual' in L[j]: ts=re.sub(r'.*\\_','',L[j+1]).split(',')[0]; break
                out.setdefault((m.group(2),m.group(3)),[]).append((m.group(1),ts))
    return out
g=lv(sys.argv[1]); o=lv(sys.argv[2])
import collections; c=collections.Counter(); ex={}
for k in g:
    a=g[k]; b=o.get(k,[])
    for x,y in zip(a,b):
        if x!=y: c[(x[0],y[0])]+=1; ex.setdefault((x[0],y[0]),[]).append(k)
for k,v in c.most_common(): print(v,k,ex[k][:4])
