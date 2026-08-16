# CENSUS of the LAW's population: every method_func_call carrying |vpiWith:.
# For each, record (call name, call span, iterator-ARG decompile+span, whether
# the arg ref binds an actual and to what).  LHS is ALWAYS golden.
import re,sys,collections
MFC=re.compile(r'^(\s*)\\_method_func_call: \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)')
def scan(path):
    lines=open(path,errors='replace').read().split('\n')
    out=[]
    for i,ln in enumerate(lines):
        m=MFC.match(ln)
        if not m: continue
        ind=len(m.group(1)); name=m.group(2)
        span='%s:%s-%s:%s'%(m.group(3),m.group(4),m.group(5),m.group(6))
        j=i+1; haswith=False; arg=None; argact=None
        while j<len(lines):
            l2=lines[j]
            if not l2.strip(): break
            ind2=len(l2)-len(l2.lstrip())
            if ind2<=ind: break
            if ind2==ind and l2.strip().startswith('\\_'): break
            s2=l2.strip()
            if ind2==ind+2 and s2=='|vpiWith:': haswith=True
            if ind2==ind+2 and s2=='|vpiArgument:' and arg is None:
                a=re.match(r'^(\s*)\\_(\w+): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)',lines[j+1])
                if a and len(a.group(1))==ind+2:
                    arg=(a.group(3),'%s:%s-%s:%s'%(a.group(4),a.group(5),a.group(6),a.group(7)))
                    # look for its actual
                    k=j+2; aind=ind+2
                    while k<len(lines):
                        l3=lines[k]
                        if not l3.strip(): break
                        ind3=len(l3)-len(l3.lstrip())
                        if ind3<=aind: break
                        if ind3==aind+2 and l3.strip()=='|vpiActual:':
                            b=re.match(r'^(\s*)\\_(\w+): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)',lines[k+1])
                            if b and len(b.group(1))==aind+2:
                                argact=(b.group(2),b.group(3),'%s:%s-%s:%s'%(b.group(4),b.group(5),b.group(6),b.group(7)))
                        k+=1
            j+=1
        if haswith: out.append((name,span,arg,argact))
    return out
g=scan(sys.argv[1]); o=scan(sys.argv[2])
print("with-clause method_func_calls: GOLDEN=%d OURS=%d"%(len(g),len(o)))
def key(x): return (x[0],x[1])
gm={key(x):x for x in g}; om={key(x):x for x in o}
print("keys shared=%d Gonly=%d Oonly=%d"%(len(set(gm)&set(om)),len(set(gm)-set(om)),len(set(om)-set(gm))))
print("-- ARG present / ARG BOUND tallies")
def tally(d,lbl):
    na=sum(1 for x in d.values() if x[2] is None)
    nb=sum(1 for x in d.values() if x[2] is not None and x[3] is not None)
    nu=sum(1 for x in d.values() if x[2] is not None and x[3] is None)
    print("   %-7s noArg=%d argBOUND=%d argUNBOUND=%d"%(lbl,na,nb,nu))
tally(gm,'GOLDEN'); tally(om,'OURS')
print("-- per-key ARG-BINDING disagreement (shared keys):")
n=0
for k in sorted(set(gm)&set(om)):
    G,O=gm[k],om[k]
    if (G[2],G[3])!=(O[2],O[3]):
        n+=1
        if n<=40: print("   %s\n      G arg=%s act=%s\n      O arg=%s act=%s"%(str(k),G[2],G[3],O[2],O[3]))
print("   disagreeing=%d"%n)

print("\n== GOLDEN full table (unique keys), sorted by span")
for k in sorted(gm, key=lambda t:(int(t[1].split(':')[0]))):
    x=gm[k]
    print("   %-18s %-22s arg=%-70s act=%s"%(x[0],x[1],str(x[2]),str(x[3])))
print("\n== OURS full table")
for k in sorted(om, key=lambda t:(int(t[1].split(':')[0]))):
    x=om[k]
    print("   %-18s %-22s arg=%-70s act=%s"%(x[0],x[1],str(x[2]),str(x[3])))
print("\n== GOLDEN-only keys:", sorted(set(gm)-set(om)))
