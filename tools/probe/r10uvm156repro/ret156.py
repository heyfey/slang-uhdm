# r10uvm156 — THE LAW'S OWN POPULATION, scored on the real corpus databases.
# Return-role class_typespec cells that pair between golden and ours, keyed by
# (line:col, role, holder kind, class_defn, parent chain).  MEASUREMENT ONLY.
import re,sys,collections
RX=re.compile(r'^\S+ CT (\S+) role=(\S+) name=(\S*) inst=(\S*) defn=(\S*) hold=(\S+)@(\d+):(\d+) via=(\S*) dhome=(\S*) ohome=(\S*) chain=(.*)$')
def load(p):
    out=collections.defaultdict(collections.Counter)
    for ln in open(p):
        m=RX.match(ln.strip())
        if not m: continue
        span,role,name,inst,defn,hold,hl,hc,via,dh,oh,chain=m.groups()
        if role!='return': continue
        out[(span.split(':',1)[1] if ':' in span else span,hold.split('(')[0],defn,chain)][(name,inst)]+=1
    return out
G,O,Q=load(sys.argv[1]),load(sys.argv[2]),load(sys.argv[3])
c=collections.Counter()
for k in set(G)&set(O)&set(Q):
    ro,rq=(O[k]==G[k]),(Q[k]==G[k])
    if ro and rq: c['RIGHT->RIGHT']+=1
    elif not ro and rq: c['WRONG->RIGHT']+=1
    elif ro and not rq: c['RIGHT->WRONG']+=1
    else:
        c['STILL-WRONG']+=1
        if O[k]!=Q[k]: c['(moved, still wrong)']+=1
onlyq=[k for k in set(Q)-set(G) if Q[k]!=O.get(k)]
c['ONLY-OURS moved']=len(onlyq)
print(f"[{sys.argv[4]}] " + "  ".join(f"{k}={v}" for k,v in sorted(c.items())))
