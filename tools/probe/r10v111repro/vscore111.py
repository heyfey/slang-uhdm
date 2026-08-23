import subprocess, sys, os, collections
CT="/tmp/v111_scratch/bin/ct111id"
env=dict(os.environ, LD_LIBRARY_PATH=os.path.expanduser("~/.local/lib64")+":"+os.path.expanduser("~/.local/lib"))
def cells(db):
    out=subprocess.run([CT,db,"::"],capture_output=True,text=True,env=env).stdout
    d=collections.Counter()
    for l in out.splitlines():
        if not l.startswith("CALL "): continue
        f=l.split()
        view=f[1]; pkg=f[2].split("=")[1].split("#")[0]; var=f[3].split("=",1)[1]
        call=f[4].split("=",1)[1]; fname=f[6].split("=",1)[1]
        shape="NONE" if fname=="<null>" else ("PKGLIST" if fname==call else "CLASSM")
        d[(view,pkg,var,call,shape)]+=1
    return d
def bykey(c):
    m=collections.defaultdict(list)
    for (v,p,var,call,shape),n in c.items(): m[(v,p,var,call)] += [shape]*n
    return {k:sorted(v) for k,v in m.items()}
g,p,q=bykey(cells(sys.argv[1])),bykey(cells(sys.argv[2])),bykey(cells(sys.argv[3]))
tg=aw=sw=ok=miss=0
for k in sorted(set(g)|set(p)|set(q)):
    G,P,Q=g.get(k,["-"]),p.get(k,["-"]),q.get(k,["-"])
    if P==G and Q==G: ok+=1; tag="ALREADY-RIGHT"
    elif P!=G and Q==G: tg+=1; tag="TO-GOLDEN"
    elif P==G and Q!=G: aw+=1; tag="** AWAY-GOLDEN **"
    else: sw+=1; tag="STILL-WRONG"
    if tag!="ALREADY-RIGHT":
        print("%-18s %-4s %-14s %-14s %-16s G=%-22s PRIS=%-22s PAT=%s"%(tag,k[0],k[1],k[2],k[3],",".join(G),",".join(P),",".join(Q)))
print("SCORE cells=%d TO-GOLDEN=%d AWAY-GOLDEN=%d STILL-WRONG=%d ALREADY-RIGHT=%d"%(len(set(g)|set(p)|set(q)),tg,aw,sw,ok))
