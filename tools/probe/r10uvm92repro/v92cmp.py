import re,sys,collections
D=sys.argv[1]
pat=re.compile(r'\\_hier_path: \((.*)\), line:(\d+):(\d+), endln:(\d+):(\d+)')
def load(f):
    d={}
    for ln in open(D+'/'+f):
        m=pat.search(ln)
        if not m: continue
        key=(int(m.group(2)),int(m.group(3)),int(m.group(4)),int(m.group(5)))
        d.setdefault(key,set()).add(m.group(1))
    return d
g=load('g.dump'); a=load('pris.dump'); b=load('pat.dump')
keys=sorted(set(g)|set(a)|set(b))
ok=fx=br=st=0
for k in keys:
    G=g.get(k); A=a.get(k); B=b.get(k)
    fmt=lambda s: '<none>' if s is None else ('|'.join(sorted(s)))
    if A==G and B==G: ok+=1; continue
    if A!=G and B==G: fx+=1; print(f"FIXED  L{k[0]}:{k[1]}  G={fmt(G)}   pris={fmt(A)}")
    elif A==G and B!=G: br+=1; print(f"*BROKE* L{k[0]}:{k[1]}  G={fmt(G)}   pat={fmt(B)}")
    else: st+=1; print(f"STILL  L{k[0]}:{k[1]}  G={fmt(G)}   pris={fmt(A)}   pat={fmt(B)}")
print(f"-- cells={len(keys)} OK={ok} FIXED={fx} BROKE={br} STILL={st}")
