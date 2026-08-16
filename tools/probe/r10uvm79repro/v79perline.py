import sys, collections, re
def load(p):
    ls=[re.sub(r'\s+',' ',l).strip() for l in open(p,errors='replace')][1:]
    d=collections.defaultdict(collections.Counter)
    for l in ls:
        m=re.search(r'line:(\d+):',l)
        d[int(m.group(1)) if m else -1][l]+=1
    return d
g,pr,pa=(load(x) for x in sys.argv[1:4])
def dist(a,b):
    return sum(abs(a[k]-b[k]) for k in set(a)|set(b))
lines=sorted(set(g)|set(pr)|set(pa))
print("%-6s %8s %8s  %s"%("line","d(g,pris)","d(g,pat)","verdict"))
for L in lines:
    dp,da=dist(g[L],pr[L]),dist(g[L],pa[L])
    if dp==0 and da==0: continue
    v = "SAME" if dp==da else ("BETTER" if da<dp else "**WORSE**")
    print("%-6d %8d %8d  %s"%(L,dp,da,v))
