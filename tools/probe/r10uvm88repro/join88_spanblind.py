# SPAN-BLIND join: `ref_obj::Compare` reads vpiName + Actual_group and NEVER the
# span, so the authoritative key is (SITE, NAME, start line:col) -- the endcol is
# a dump axis and keying on it split four Scoreboard binds that AGREE.
import sys, collections
def load(p):
    d=collections.defaultdict(list)
    for l in open(p):
        l=l.rstrip('\n')
        if not l: continue
        f=l.split('\t')
        span=f[0].split('|',1)[-1].split('-')[0]
        r=dict(x.split('=',1) for x in f[1:])
        d[(r['SITE'],r['NAME'])].append((r['ACT'],r['ACTFULL']))
    return d
g=load(sys.argv[1]); o=load(sys.argv[2]); tag=sys.argv[3]
gk=set(g); ok=set(o); extra=[]; miss=[]; agree=0
for k in sorted(gk|ok):
    ga=sorted(g.get(k,[])); oa=sorted(o.get(k,[]))
    if ga==oa: agree+=1; continue
    if not ga: extra.append((k,oa))
    elif not oa: miss.append((k,ga))
    else: extra.append((k,('COUNT',len(ga),len(oa))))
print("[%s] keys=%d agree=%d EXTRA-OURS=%d MISSING-OURS=%d"%(tag,len(gk|ok),agree,len(extra),len(miss)))
for k,v in extra: print("  EXTRA %-60s %-28s %s"%(k[0],k[1],v))
for k,v in miss:  print("  MISS  %-60s %-28s %s"%(k[0],k[1],v[0]))
