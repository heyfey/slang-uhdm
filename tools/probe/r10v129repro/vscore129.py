#!/usr/bin/env python3
# r10v129 verifier scorer: join golden / pristine / patched censuses by
# array_var NAME (unique per verifier grid) and score the LAW FIELD only.
import sys, collections
def load(p):
    d={}
    for ln in open(p):
        if not ln.startswith('CELL\t'): continue
        f=ln.rstrip('\n').split('\t')
        arr=f[2].split('|'); ev=f[4].split('|'); ts=f[5].split('|')
        name=arr[1]
        d.setdefault(name,[]).append(dict(site=f[1],dim=arr[3],evkind=ev[0],
            sgn=ev[3],auto=ev[4],arrmem=ev[5],tskind=ts[0],tsname=ts[1],raw=ln.rstrip('\n')))
    return d
g,o,q=load(sys.argv[1]),load(sys.argv[2]),load(sys.argv[3])
tag=sys.argv[4]
cnt=collections.Counter()
for name in sorted(set(g)|set(o)|set(q)):
    G,O,Q=g.get(name),o.get(name),q.get(name)
    if not G:
        cnt['ONLY-OURS' if O else 'ONLY-PATCHED']+=1
        if (O is None)!=(Q is None): cnt['OBJSET-DRIFT']+=1
        continue
    if not O and not Q:
        cnt['ONLY-GOLDEN']+=1; continue
    if not O or not Q:
        cnt['OBJSET-DRIFT']+=1; continue
    gs,os_,qs=G[0]['sgn'],O[0]['sgn'],Q[0]['sgn']
    if gs==os_ and gs==qs: verdict='SAME-OK'
    elif gs!=os_ and gs==qs: verdict='LAW-FIXED'
    elif gs==os_ and gs!=qs: verdict='LAW-BROKE'
    elif gs!=os_ and gs!=qs and os_==qs: verdict='LAW-STILL-WRONG'
    else: verdict='LAW-CHANGED-STILL-WRONG'
    cnt[verdict]+=1
    # collateral: any other field moved pris->pat
    for k in ('evkind','auto','arrmem','tskind','tsname','dim','site'):
        if O[0][k]!=Q[0][k]: cnt['COLLATERAL:'+k]+=1
    if verdict!='SAME-OK':
        print("%s %-16s %-28s G=%s P=%s Q=%s  %s  gts=%s/%s ots=%s"%(tag,verdict,name,gs,os_,qs,O[0]['evkind'],G[0]['tskind'],G[0]['tsname'],O[0]['tskind']))
print(tag,"TOTALS",dict(sorted(cnt.items())))
