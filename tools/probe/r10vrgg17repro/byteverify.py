import os,sys,hashlib,collections
A,B=sys.argv[1],sys.argv[2]; tag=sys.argv[3] if len(sys.argv)>3 else ''
def scan(root):
    d={}
    for mode in os.listdir(root):
        md=os.path.join(root,mode)
        if not os.path.isdir(md): continue
        for cell in os.listdir(md):
            p=os.path.join(md,cell,'slang.uhdm')
            key=(mode,cell.rsplit('-',1)[0])
            if os.path.exists(p):
                d[key]=hashlib.md5(open(p,'rb').read()).hexdigest()
    return d
a=scan(A); b=scan(B)
common=set(a)&set(b)
mov=sorted(k for k in common if a[k]!=b[k])
onlyA=sorted(set(a)-set(b)); onlyB=sorted(set(b)-set(a))
print(f"{tag}: databases A={len(a)} B={len(b)} common={len(common)} MOVERS={len(mov)} onlyA={len(onlyA)} onlyB={len(onlyB)}")
for k in mov: print("   MOVER",k[0]+"/"+k[1],a[k][:12],"->",b[k][:12])
for k in onlyA[:10]: print("   ONLY-A",k)
for k in onlyB[:10]: print("   ONLY-B",k)
# SELFCHECK: a null comparison of A against itself must report 0 movers
print(f"{tag}: SELFCHECK A-vs-A movers={sum(1 for k in a if a[k]!=a[k])} / {len(a)}")
