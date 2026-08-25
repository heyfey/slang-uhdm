import sys,os,subprocess,collections
CEN="/tmp/v146_cen"
root=sys.argv[1]
def cen(p):
    if not os.path.exists(p): return None
    r=subprocess.run([CEN,p],capture_output=True,text=True)
    return r.stdout.splitlines()
for arm in sorted(os.listdir(root)):
    d=os.path.join(root,arm)
    if not os.path.isdir(d): continue
    for view,g,pp,qq in (("DEF","slD","pD.uhdm","qD.uhdm"),("ELAB","slE","pE.uhdm","qE.uhdm")):
        G=os.path.join(d,g,"slpp_all","surelog.uhdm")
        if not os.path.exists(G): G=os.path.join(d,g,"surelog.uhdm")
        gl=cen(G); pl=cen(os.path.join(d,pp)); ql=cen(os.path.join(d,qq))
        if gl is None or pl is None or ql is None:
            print(f"[{arm}/{view}] MISSING DB"); continue
        def lst(x): return [l for l in x if l.startswith("LIST")]
        gL,pL,qL=lst(gl),lst(pl),lst(ql)
        listok = "SAME" if gL==qL else "DIFF"
        # REF rows keyed by name+loc
        def refs(x):
            m=collections.Counter()
            for l in x:
                if l.startswith("REF|"):
                    f=l.split("|")
                    m[(f[1],f[2])] += 0
                    m[(f[1],f[2],f[4],f[6])] += 1
            return m
        def refmap(x):
            m=collections.defaultdict(collections.Counter)
            for l in x:
                if l.startswith("REF|"):
                    f=l.split("|")
                    m[(f[1],f[2])][ (f[4],f[5],f[6]) ] += 1
            return m
        gm,pm,qm=refmap(gl),refmap(pl),refmap(ql)
        regress=[]
        for k in set(pm)|set(qm):
            if pm.get(k)!=qm.get(k):
                gv=gm.get(k)
                if gv is None:
                    regress.append(("NO-GOLD-KEY",k,dict(pm.get(k,{})),dict(qm.get(k,{}))))
                elif pm.get(k)==gv and qm.get(k)!=gv:
                    regress.append(("PRIS-RIGHT-PAT-WRONG",k,dict(gv),dict(qm.get(k,{}))))
                elif qm.get(k)==gv:
                    pass # improvement
                else:
                    regress.append(("BOTH-WRONG-MOVED",k,dict(gv),dict(qm.get(k,{}))))
        print(f"[{arm}/{view}] LISTING golden={len(gL)} pris={len(pL)} pat={len(qL)} pat==golden:{listok}  REFMOVES={len(regress)}")
        if gL!=qL:
            for a,b in zip(gL+['']*max(0,len(qL)-len(gL)), qL+['']*max(0,len(gL)-len(qL))):
                if a!=b: print(f"    LISTDIFF gold={a!r} pat={b!r}")
        for r in regress[:12]:
            print("    ",r)
