#!/usr/bin/env python3
# 3-way multiset join: golden x pristine x patched, per (key,payload) with counts.
import sys, collections
def load(p):
    c=collections.Counter()
    for ln in open(p):
        ln=ln.rstrip('\n')
        if not ln: continue
        n,k,v=ln.split('\t',2)
        c[(k,v)]+=int(n)
    return c
G,P,Q=[load(x) for x in sys.argv[1:4]]
keys=set(k for k,_ in G)|set(k for k,_ in P)|set(k for k,_ in Q)
tg=ag=sw=mn=add=rem=0
det=[]
for key in sorted(keys):
    g={v:n for (k,v),n in G.items() if k==key}
    p={v:n for (k,v),n in P.items() if k==key}
    q={v:n for (k,v),n in Q.items() if k==key}
    if p==q: continue
    # something moved at this key
    payloads=set(g)|set(p)|set(q)
    for v in sorted(payloads):
        gp,pp,qp=g.get(v,0),p.get(v,0),q.get(v,0)
        if pp==qp: continue
        if qp>pp:   # added copies of payload v
            verdict='TO-GOLDEN' if gp>0 and qp<=gp else ('ADDED-NO-GOLDEN' if gp==0 else 'TO-GOLDEN-OVER')
        else:
            verdict='LEFT-GOLDEN' if gp>0 else 'LEFT-WRONG'
        det.append((key,v,gp,pp,qp,verdict))
for d in det:
    print('%-90s | g=%d p=%d q=%d | %-16s | %s' % (d[0][:90], d[2],d[3],d[4], d[5], d[1][:150]))
# summary
mov=collections.Counter(d[5] for d in det)
print('SUMMARY', dict(mov))
