import re,sys,collections,os
def norm(p, root):
    out=[]
    for l in open(p, errors='replace'):
        l=l.rstrip('\n')
        l=l.replace(root,'WD')
        l=re.sub(r', id:\d+','',l)
        l=re.sub(r'id:\d+','id:N',l)
        out.append(l)
    return collections.Counter(out)
def dsz(a,b):
    d=a-b
    return sum(d.values())
arms=sys.argv[1:]
print("%-20s %8s %8s %8s %8s %s"%("arm","pris_ex","law_ex","pris_mis","law_mis","verdict"))
for a in arms:
    pr='/tmp/v11u10_grid_pris/'+a; lw='/tmp/v11u10_grid_law/'+a
    if not os.path.exists(pr+'/ours.dump'): continue
    gp=norm(pr+'/gold.dump',pr); op=norm(pr+'/ours.dump',pr)
    gl=norm(lw+'/gold.dump',lw); ol=norm(lw+'/ours.dump',lw)
    # extra = lines we have golden doesn't ; missing = lines golden has we don't
    pe,pm=dsz(op,gp),dsz(gp,op)
    le,lm=dsz(ol,gl),dsz(gl,ol)
    v='SAME'
    if le+lm < pe+pm: v='FIXED'
    elif le+lm > pe+pm: v='WORSE'
    print("%-20s %8d %8d %8d %8d %s"%(a,pe,le,pm,lm,v))
