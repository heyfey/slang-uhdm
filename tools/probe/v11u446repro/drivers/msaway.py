import sys,collections
def ms(f): return collections.Counter(l.rstrip('\n') for l in open(f))
g,p,l=(ms(x) for x in sys.argv[1:4])
keys=set(g)|set(p)|set(l)
away=[(k,g[k],p[k],l[k]) for k in keys if abs(l[k]-g[k])>abs(p[k]-g[k])]
closer=sum(1 for k in keys if abs(l[k]-g[k])<abs(p[k]-g[k]))
print("away",len(away),"closer",closer)
for a in sorted(away)[:15]: print("  g=%d p=%d l=%d | %s"%(a[1],a[2],a[3],a[0][:220]))
