import sys, re, collections
def norm(fn):
    out=[]
    for l in open(fn,errors="replace").read().splitlines()[1:]:
        l=re.sub(r", id:\d+","",l)
        l=re.sub(r"file:[^,]*","file:F",l)
        out.append(l.strip())
    return collections.Counter(out)
g=norm(sys.argv[1]); o=norm(sys.argv[2])
go=sum((g-o).values()); oo=sum((o-g).values())
print("gold_only=%d ours_only=%d"%(go,oo))
if len(sys.argv)>3 and sys.argv[3]=="v":
    for k,v in sorted((o-g).items()): print("  OURS_ONLY x%d %s"%(v,k))
    for k,v in sorted((g-o).items()): print("  GOLD_ONLY x%d %s"%(v,k))
