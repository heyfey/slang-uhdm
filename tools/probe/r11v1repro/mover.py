import sys,collections,re
def norm(p,tag):
    out=[]
    for l in open(p):
        l=l.rstrip('\n')
        l=re.sub(r'/w_(pris|pat)/','/W/',l)
        out.append(l)
    return out
g=collections.Counter(norm(sys.argv[1],'g'))
p=collections.Counter(norm(sys.argv[2],'p'))
q=collections.Counter(norm(sys.argv[3],'q'))
gp=g&p; gq=g&q
lost=gp-gq; gained=gq-gp
print("agree_pris=%d agree_pat=%d LOST=%d GAINED=%d"%(sum(gp.values()),sum(gq.values()),sum(lost.values()),sum(gained.values())))
for k,v in sorted(lost.items()):
    print("  LOST x%d %s"%(v,k))
