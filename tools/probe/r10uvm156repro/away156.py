# r10uvm156 — the AWAY / MOVED-WRONG audit, scored EXPLICITLY in both columns.
# AWAY  = a NAME written where golden has NONE, or a SPELLING golden does not
#         use, on a cell that pairs with a golden cell.
# MOVED-WRONG = a cell that was RIGHT in pristine and is WRONG in patched.
# MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.
import re,sys,collections
RX=re.compile(r'^\S+ CT (\S+) role=(\S+) name=(\S*) inst=(\S*) defn=(\S*) hold=(\S+)@(\d+):(\d+) via=(\S*) dhome=(\S*) ohome=(\S*) chain=(.*)$')
def load(p):
    out=collections.defaultdict(collections.Counter)
    for ln in open(p):
        m=RX.match(ln.strip())
        if not m: continue
        span,role,name,inst,defn,hold,hl,hc,via,dh,oh,chain=m.groups()
        out[(span.split(':',1)[1] if ':' in span else span,role,hold.split('(')[0],defn,chain)][name]+=1
    return out
G,O,Q=load(sys.argv[1]),load(sys.argv[2]),load(sys.argv[3])
tag=sys.argv[4] if len(sys.argv)>4 else 'ARM'
c=collections.Counter(); ex=[]
for k in set(G)&set(Q):
    gn=set(G[k]); on=set(O.get(k,{})); qn=set(Q[k])
    if qn==gn: c['NAME-RIGHT']+=1
    elif gn=={'-'}: c['AWAY(name-where-golden-bare)']+=1; ex.append((k,gn,on,qn))
    elif qn<=gn or (len(qn-gn)==1 and '-' in (qn-gn)): c['NAME-PARTIAL(missing)']+=1
    else: c['AWAY(spelling)']+=1; ex.append((k,gn,on,qn))
    if on==gn and qn!=gn: c['MOVED-WRONG']+=1; ex.append(('MW',k,gn,on,qn))
print(f"[{tag}] " + "  ".join(f"{k}={v}" for k,v in sorted(c.items())))
for e in ex[:12]: print("    ",e)
