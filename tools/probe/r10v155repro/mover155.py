import sys
def load(p):
    d={}
    for ln in open(p):
        f=ln.rstrip("\n").split("\t")
        d[f[1]]=(f[0],f[2],f[3])
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
tw=[];wr=[];sm=0
for k in sorted(set(a)|set(b)):
    ta=a.get(k,("ABSENT","",""))[0]; tb=b.get(k,("ABSENT","",""))[0]
    if ta==tb: sm+=1; continue
    if tb=="SAME": tw.append(k)
    else: wr.append((k,ta,tb,a.get(k,("","",""))[1],a.get(k,("","",""))[2],b.get(k,("","",""))[2]))
print("UNCHANGED=%d MOVED_TOWARD=%d MOVED_WRONG=%d"%(sm,len(tw),len(wr)))
for k,x,y,gg,op,on in wr:
    print("WRONG %s->%s  %s\n   %s\n   PRIS %s\n   PAT  %s"%(x,y,k,gg,op,on))
for k in tw: print("TOWARD  %s"%k)
