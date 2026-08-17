import sys, collections
def load(p):
    d=collections.defaultdict(list)
    for l in open(p):
        l=l.rstrip('\n')
        if not l: continue
        f=l.split('\t')
        span=f[0].split('|',1)[-1]
        r=dict(x.split('=',1) for x in f[1:])
        d[(r['SITE'],span,r['NAME'])].append(r)
    return d
g=load(sys.argv[1]); o=load(sys.argv[2]); tag=sys.argv[3]
gk=set(g); ok=set(o)
extra=[]; missing=[]; agree=0
for k in sorted(gk|ok):
    ga=sorted((x['ACT'],x['ACTFULL']) for x in g.get(k,[]))
    oa=sorted((x['ACT'],x['ACTFULL']) for x in o.get(k,[]))
    gb=[x for x in ga if x[0]!='<null>']; ob=[x for x in oa if x[0]!='<null>']
    if len(gb)==len(ob) and gb==ob: agree+=1; continue
    if not gb and ob: extra.append((k,len(ob),ob[0]))
    elif gb and not ob: missing.append((k,len(gb),gb[0]))
    else: extra.append((k,('MIX',ga,oa),''))
print("[%s] keys=%d agree=%d EXTRA-OURS=%d MISSING-OURS=%d"%(tag,len(gk|ok),agree,len(extra),len(missing)))
for k,n,a in extra: print("  EXTRA  %-58s %-30s %s x%s %s"%(k[0],k[2],k[1],n,a))
for k,n,a in missing: print("  MISS   %-58s %-30s %s x%s %s"%(k[0],k[2],k[1],n,a))
