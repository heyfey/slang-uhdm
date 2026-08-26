import sys
def load(p):
    d={}
    for ln in open(p):
        f=ln.rstrip("\n").split("\t")
        d[f[1]]=(f[0],f[2],f[3])
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
n=0
for k in sorted(set(a)&set(b)):
    if a[k][0]=="DIFF" and b[k][0]=="DIFF" and a[k][2]!=b[k][2]:
        n+=1; print("RESHAPE %s\n   %s\n   PRIS %s\n   PAT  %s"%(k,a[k][1],a[k][2],b[k][2]))
print("RESHAPE_COUNT=%d"%n)
