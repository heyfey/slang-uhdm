import re,sys,collections
def load(p):
    d=collections.Counter()
    for ln in open(p):
        if not ln.startswith('DB K '): continue
        ln=ln.rstrip('\n')
        ln=re.sub(r' id=\d+$','',ln)
        ln=re.sub(r'rel=[0-9,]*v?','',ln)
        m=re.match(r'DB K (\S*?):(\d+):(\d+)-(\d+):(\d+) ct=(\S+) size=(\S+) dec=\[(.*?)\] val=\[(.*?)\] ts=(\S+) par=(\S+) own=(\S+)@\S*?:(\d+):(\d+)\s+home=(\S+) chain=(\S*)',ln)
        if not m:
            continue
        key=(m.group(2),m.group(3),m.group(4),m.group(5),m.group(6),m.group(7),m.group(8),m.group(9),m.group(12),m.group(13),m.group(14),m.group(15))
        ts=re.sub(r'@\S*?:',r'@:',m.group(10))
        d[(key,ts)]+=1
    return d
g=load(sys.argv[1]); a=load(sys.argv[2]); b=load(sys.argv[3])
# group by key
def bykey(d):
    r=collections.defaultdict(collections.Counter)
    for (k,ts),n in d.items(): r[k][ts]+=n
    return r
G,A,B=bykey(g),bykey(a),bykey(b)
away=[];to=[];moved=[];newmis=[]
for k in sorted(set(A)|set(B)):
    if A[k]==B[k]: continue
    gt=G.get(k)
    print("KEY",k)
    print("   GOLD",dict(gt) if gt else None)
    print("   PRIS",dict(A.get(k,{})))
    print("   PAT ",dict(B.get(k,{})))
    if gt is None:
        print("   -> NO-GOLDEN-KEY")
    else:
        pa = A.get(k,collections.Counter()); pb=B.get(k,collections.Counter())
        da = sum((gt-pa).values())+sum((pa-gt).values())
        db = sum((gt-pb).values())+sum((pb-gt).values())
        print("   -> distance pris=%d pat=%d %s"%(da,db,"TO-GOLDEN" if db<da else ("AWAY" if db>da else "SIDEWAYS")))
