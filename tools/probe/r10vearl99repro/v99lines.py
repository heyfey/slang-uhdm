import sys, re, collections
# 3-way cell census over uhdm-dump text: key = (object header chain tail, attribute)
def keys(path):
    ctx=[]; out=collections.Counter()
    for raw in open(path, errors='replace'):
        line=raw.rstrip('\n')
        ind=len(line)-len(line.lstrip(' '))
        s=line.strip()
        if s.startswith('\\_'):
            hdr=re.sub(r'\(work@[^)]*\)','(OBJ)',s)
            hdr=re.sub(r'file:[^,]*,','',hdr)
            while ctx and ctx[-1][0]>=ind: ctx.pop()
            ctx.append((ind,hdr))
        elif s.startswith('|') and ':' in s:
            parent=ctx[-1][1] if ctx else ''
            gp=ctx[-2][1] if len(ctx)>1 else ''
            out[(gp,parent,s)]+=1
    return out
g,p,c=[keys(x) for x in sys.argv[1:4]]
allk=set(g)|set(p)|set(c)
to=away=same=0; det=[]
for k in allk:
    a,b,d=g[k],p[k],c[k]
    if b==d: continue
    if abs(d-a)<abs(b-a): to+=1; det.append(('TO',k,a,b,d))
    elif abs(d-a)>abs(b-a): away+=1; det.append(('AWAY',k,a,b,d))
    else: same+=1; det.append(('LATERAL',k,a,b,d))
print(f"TO-GOLDEN {to}  AWAY-GOLDEN {away}  LATERAL {same}")
for t,k,a,b,d in sorted(det):
    print(f"  {t} g={a} p={b} c={d} :: {k[1][:70]} || {k[2][:90]}")
