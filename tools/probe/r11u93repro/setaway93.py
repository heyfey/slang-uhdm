import sys, re
def norm(fn):
    out=set()
    for l in open(fn,errors="replace").read().splitlines()[1:]:
        l=re.sub(r", id:\d+","",l); l=re.sub(r"file:[^,]*","file:F",l)
        out.add(l.strip())
    return out
gp=norm(sys.argv[1]); op=norm(sys.argv[2]); gq=norm(sys.argv[3]); oq=norm(sys.argv[4])
mp=gp&op; mq=gq&oq
away=mp-mq; conv=mq-mp
print("SETWISE matched_pris=%d matched_patch=%d CONV=%d AWAY=%d"%(len(mp),len(mq),len(conv),len(away)))
for k in sorted(away): print("   AWAY %s"%k)
