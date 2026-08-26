# r10uvm156 — ARM SCORER.  Joins the ct156cen census of GOLDEN, PRISTINE and
# PATCHED for one arm-view and reports every class_typespec cell as
# RIGHT->RIGHT / WRONG->RIGHT / RIGHT->WRONG / STILL-WRONG, plus the one-sided
# sets.  MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.  The key excludes VpiFile
# (ours leaves it empty on a class_typespec; Compare never reads it) and the
# DEF/ELAB view; the payload is the COMPARE-VISIBLE (VpiName, vpiInstance).
import re,sys,collections
RX=re.compile(r'^\S+ CT (\S+) role=(\S+) name=(\S*) inst=(\S*) defn=(\S*) hold=(\S+)@(\d+):(\d+) via=(\S*) dhome=(\S*) ohome=(\S*) chain=(.*)$')
def load(p):
    out=collections.defaultdict(collections.Counter)
    for ln in open(p):
        m=RX.match(ln.strip())
        if not m: continue
        span,role,name,inst,defn,hold,hl,hc,via,dh,oh,chain=m.groups()
        k=(span.split(':',1)[1] if ':' in span else span,role,hold.split('(')[0],defn,chain)
        out[k][(name,inst)]+=1
    return out
G,O,Q=load(sys.argv[1]),load(sys.argv[2]),load(sys.argv[3])
tag=sys.argv[4] if len(sys.argv)>4 else 'ARM'
c=collections.Counter(); moved=[]
for k in set(G)&set(O)&set(Q):
    g,o,q=G[k],O[k],Q[k]
    ro,rq=(o==g),(q==g)
    if   ro and rq: c['RIGHT->RIGHT']+=1
    elif not ro and rq: c['WRONG->RIGHT']+=1; moved.append(('WRONG->RIGHT',k,dict(g),dict(o),dict(q)))
    elif ro and not rq: c['RIGHT->WRONG']+=1; moved.append(('RIGHT->WRONG',k,dict(g),dict(o),dict(q)))
    else:
        c['STILL-WRONG']+=1
        if o!=q: c['  (moved, still wrong)']+=1; moved.append(('MOVED-STILL-WRONG',k,dict(g),dict(o),dict(q)))
for k in set(O)|set(Q):
    if k in G: continue
    if O.get(k)!=Q.get(k): c['ONLY-OURS moved']+=1
    else: c['ONLY-OURS same']+=1
c['ONLY-GOLDEN']=len(set(G)-set(O)-set(Q))
print(f"[{tag}] " + "  ".join(f"{k}={v}" for k,v in sorted(c.items())))
for m in moved[:int(sys.argv[5]) if len(sys.argv)>5 else 0]:
    print("   ",m[0],m[1][:3],m[1][4][:60]); print("        G",m[2]); print("        O",m[3]); print("        Q",m[4])
