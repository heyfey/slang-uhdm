import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        f = ln.split()
        if len(f) < 4 or f[2] in ('NODB','NOCONST','DUMPFAIL'):
            d[(f[1],'META')].append(' '.join(f[2:])); continue
        arm, sect, key = f[1], f[2], f[3]
        rest = ' '.join(f[5:])
        d[(arm, sect+' '+key)].append(rest)
    return d
G = load(sys.argv[1]); P = load(sys.argv[2]); L = load(sys.argv[3])
keys = sorted(set(G)|set(P)|set(L))
stat = collections.Counter()
for k in keys:
    g = '; '.join(G.get(k,['<none>'])); p = '; '.join(P.get(k,['<none>'])); l = '; '.join(L.get(k,['<none>']))
    if 'size=?' in g and 'size=?' in p and 'size=?' in l:
        continue  # back-reference in all three: no own object
    pe = (g==p); le = (g==l)
    if pe and le: s='EQ_EQ'
    elif not pe and le: s='CONVERT'
    elif pe and not le: s='REGRESS'
    elif not pe and not le and p==l: s='DIFF_UNMOVED'
    else: s='DIFF_MOVED_WRONG'
    stat[s]+=1
    print('%-4s %-14s %-16s GOLD[%s] PRIS[%s] LAW[%s]'%(k[0],k[1],s,g,p,l))
print('---', dict(stat))
