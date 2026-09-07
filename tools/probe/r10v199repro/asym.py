import sys,collections
for p in sys.argv[1:]:
    par={}; lhs={}
    for ln in open(p):
        ln=ln.rstrip('\n')
        if '\t' not in ln: continue
        k,rest=ln.split('\t',1)
        v,ok,on,listing,idx,pn=k.split('|')[:6]
        ts=rest.split('\t')[0]
        if listing=='Parameters': par.setdefault((v,on,pn),collections.Counter())[ts]+=1
        elif listing=='PA.Lhs':   lhs.setdefault((v,on,pn),collections.Counter())[ts]+=1
    bad=[]
    for k in set(par)|set(lhs):
        a=par.get(k,collections.Counter()); b=lhs.get(k,collections.Counter())
        if a!=b: bad.append((k,dict(a),dict(b)))
    print(f"{p} ASYM={len(bad)}")
    for x in bad[:6]: print("   ",x)
