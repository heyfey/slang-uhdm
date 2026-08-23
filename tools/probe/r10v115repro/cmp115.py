import sys, collections
# join golden vs ours on (viewsuffix, SITE, OWNER, LC, NM); payload = VK,TSK,TSN,TSI
def load(p):
    m = collections.Counter()
    for ln in open(p, errors='replace'):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 14 or f[1] not in ('LOCAL','RET','IODECL','PROP','VAR','DECL'):
            continue
        view = f[0].split('.')[-1]
        key = (view, f[1], f[5], f[6], f[7])
        pay = (f[8], f[10], f[11], f[12])
        m[(key,pay)] += 1
    return m
G = load(sys.argv[1]); P = load(sys.argv[2]); Q = load(sys.argv[3])
def bykey(m):
    d = collections.defaultdict(collections.Counter)
    for (k,pay),n in m.items(): d[k][pay] += n
    return d
gd, pd_, qd = bykey(G), bykey(P), bykey(Q)
keys = sorted(set(gd)|set(pd_)|set(qd))
npris=npat=0
for k in keys:
    g, p, q = gd.get(k,collections.Counter()), pd_.get(k,collections.Counter()), qd.get(k,collections.Counter())
    dp = (g!=p); dq = (g!=q)
    if dp: npris+=1
    if dq: npat+=1
    if dp or dq:
        st = 'FIXED' if (dp and not dq) else ('REGRESSION' if (dq and not dp) else 'STILL')
        print("%-11s %s" % (st, ' | '.join(k)))
        print("      G  : %s" % (dict(g) or '-'))
        print("      pri: %s" % (dict(p) or '-'))
        print("      pat: %s" % (dict(q) or '-'))
print("SUMMARY keys=%d pristine-differ=%d patched-differ=%d" % (len(keys), npris, npat))
