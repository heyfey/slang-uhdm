import sys, os, glob, collections
# OWNER-KEYED census, Compare-visible payload only: (typespec KIND, ref VpiName).
# key = (cast operation SPAN, owner vpiFullName).  Multiset per key.
def load(p):
    d=collections.defaultdict(collections.Counter)
    if not os.path.exists(p): return d
    for l in open(p, errors='replace'):
        c=l.rstrip('\n').split('\t')
        if len(c)<9: continue
        d[(c[0],c[7])][(c[1],c[4])]+=1
    return d
root=sys.argv[1]
tot=collections.Counter(); gcells=0; away=[]; togold=collections.Counter()
dbs=0
for g in sorted(glob.glob(root+'/*.g')):
    base=g[:-2]; dbs+=1
    G,P,R=load(g),load(base+'.p'),load(base+'.r')
    gcells+=sum(sum(v.values()) for v in G.values())
    for k in set(G)|set(P)|set(R):
        a,p,r=G[k],P[k],R[k]
        if r==a and p==a: v='ALREADY-OK'
        elif r!=a and p==a: v='TO-GOLDEN'
        elif r==a and p!=a: v='AWAY'
        else:
            dr=sum((a-r).values())+sum((r-a).values()); dp=sum((a-p).values())+sum((p-a).values())
            v='STILL-CLOSER' if dp<dr else ('STILL-FARTHER' if dp>dr else 'STILL')
        tot[v]+=1
        if v=='TO-GOLDEN': togold[(tuple(sorted(r)),tuple(sorted(a)))]+=1
        if v in ('AWAY','STILL-FARTHER'):
            away.append('%s %s %s G=%s PRI=%s PAT=%s'%(v,os.path.basename(base),k,dict(a),dict(r),dict(p)))
print('DBS %d  GOLDEN_CAST_CELLS %d'%(dbs,gcells), dict(tot))
for (fr,to),n in togold.most_common():
    print('  TO-GOLDEN x%d  ours-was=%s -> golden=%s'%(n,fr,to))
for a in away[:40]: print('  '+a)
