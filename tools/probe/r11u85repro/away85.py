import sys, re, collections
def norm(fn):
    out=[]
    for l in open(fn,errors="replace").read().splitlines()[1:]:
        l=re.sub(r", id:\d+","",l); l=re.sub(r"file:[^,]*","file:F",l)
        out.append(l.strip())
    return collections.Counter(out)
gp=norm(sys.argv[1]); op=norm(sys.argv[2])   # pristine pair
gq=norm(sys.argv[3]); oq=norm(sys.argv[4])   # patched pair
mp = gp & op   # golden lines we matched, pristine
mq = gq & oq   # golden lines we matched, patched
away = mp - mq          # golden lines we USED to match and no longer do
conv = mq - mp
print("MATCHED_pris=%d MATCHED_patch=%d CONVERTED=%d AWAY=%d"%(sum(mp.values()),sum(mq.values()),sum(conv.values()),sum(away.values())))
for k,v in sorted(away.items()): print("   AWAY x%d %s"%(v,k))
