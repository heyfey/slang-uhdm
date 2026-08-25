import sys, re, collections
def load(p):
    d=collections.defaultdict(list)
    for ln in open(p):
        ln=ln.rstrip('\n')
        if '|' not in ln: continue
        k,v=ln.split('|',1)
        f=dict(x.split('=',1) for x in v.split() if '=' in x)
        d[k.strip()].append((f.get('OV'), f.get('IMP','-')))
    for k in d: d[k].sort()
    return d
g,o,q=(load(a) for a in sys.argv[1:4])
lab=sys.argv[4]
for k in sorted(set(g)|set(o)|set(q)):
    if 'VIEW=ELAB' not in k: continue
    gl,ol,ql=g.get(k,[]),o.get(k,[]),q.get(k,[])
    n=max(len(gl),len(ol),len(ql))
    for i in range(n):
        a=gl[i] if i<len(gl) else None
        b=ol[i] if i<len(ol) else None
        c=ql[i] if i<len(ql) else None
        if a and b and c and a[0]==b[0]==c[0]: continue
        print(f"{lab} {k} golden={a} pris={b} patch={c}")
