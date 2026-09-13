import re,sys,os,subprocess,collections
DUMP='/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
def golden_of(d):
    c=os.path.join(d,'cmds.txt')
    t=open(c,errors='replace').read()
    m=re.search(r'golden cache hit (/[^\s)]+)',t)
    if not m: return None
    g=m.group(1)
    if os.path.isdir(g): g=os.path.join(g,'golden.uhdm')
    return g if os.path.isfile(g) else None
def dump(p):
    r=subprocess.run([DUMP,p],capture_output=True,text=True)
    out=[]
    for l in r.stdout.splitlines():
        l=re.sub(r', id:\d+','',l)
        l=re.sub(r"file:[^,]*,","file:F,",l).strip()
        out.append(l)
    return collections.Counter(out)
rows=sys.argv[1:]
tot_to=tot_away=0
awaylines=collections.Counter()
for mode in ('default','testflags'):
    for r in rows:
        pd=None
        import glob
        for d in glob.glob('/tmp/v11u10_wd_pris/u2r/%s/%s-*'%(mode,r)): pd=d
        ld=None
        for d in glob.glob('/tmp/v11u10_wd_law/u2r/%s/%s-*'%(mode,r)): ld=d
        if not pd or not ld: print("MISS",mode,r); continue
        g=golden_of(pd)
        if not g: print("NOGOLD",mode,r); continue
        G=dump(g); P=dump(os.path.join(pd,'slang.uhdm')); L=dump(os.path.join(ld,'slang.uhdm'))
        # per-line: distance to golden before and after
        keys=set(G)|set(P)|set(L)
        to=away=0
        for k in keys:
            dp=abs(G[k]-P[k]); dl=abs(G[k]-L[k])
            if dl<dp: to+=dp-dl
            elif dl>dp:
                away+=dl-dp
                awaylines[k.strip()]+=dl-dp
        tot_to+=to; tot_away+=away
        print("%-32s %-9s TO=%6d AWAY=%6d"%(r,mode,to,away))
print("TOTAL TO-GOLDEN=%d  TOTAL AWAY-GOLDEN=%d"%(tot_to,tot_away))
print("--- distinct AWAY lines ---")
for k,v in awaylines.most_common(30): print("%6d  %s"%(v,k))
