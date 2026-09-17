import sys
def shapes(p):
    d={}
    for l in open(p,errors='replace'):
        f=l.split()
        if f and f[0]=='SHAPE' and f[2].startswith('elab'):
            d[(f[1],f[2],f[3],f[4])]=f[5]
    return d
g=shapes(sys.argv[1]); o=shapes(sys.argv[2])
gf=to=0; rows=set()
for k,v in g.items():
    if k in o:
        if v=='TAGGED' and o[k]=='FLAT': to+=1; rows.add(('TAGGED->FLAT',)+k)
        if v=='FLAT' and o[k]=='TAGGED': gf+=1
print('joined=%d GOLDTAGGED_OURSFLAT=%d GOLDFLAT_OURSTAGGED=%d' % (len(set(g)&set(o)), to, gf))
for r in sorted(rows)[:10]: print('  ',r)
