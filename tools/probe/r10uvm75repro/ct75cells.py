# r10uvm75 PER-CELL table.  Every ref_obj/ref_var whose vpiName is one of the
# NAMES, on BOTH sides, keyed by (decompile, span), with its PARENT kind and
# its vpiActual.  LHS is ALWAYS golden.
#   usage: ct75cells.py <golden.dump> <ours.dump> [name ...]
# A key present on only one side prints ABSENT on the other and COUNTS as a
# disagreement -- a one-sided cell must never read as agreement.
import re,sys,collections
REF=re.compile(r'^(\s*)\\_(ref_obj|ref_var): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)')
NAMES=set(sys.argv[3:]) or {'item','node'}   # names to table, from argv
def scan(path):
    lines=open(path,errors='replace').read().split('\n')
    out={}
    for i,ln in enumerate(lines):
        m=REF.match(ln)
        if not m: continue
        ind=len(m.group(1)); dec=m.group(3)
        span='%s:%s-%s:%s'%(m.group(4),m.group(5),m.group(6),m.group(7))
        j=i+1; nm=None; act='NONE'; par=None
        while j<len(lines):
            l2=lines[j]
            if not l2.strip(): break
            ind2=len(l2)-len(l2.lstrip())
            if ind2<=ind: break
            s2=l2.strip()
            if ind2==ind+2 and s2.startswith('|vpiName:'): nm=s2[9:]
            if ind2==ind+2 and s2=='|vpiParent:':
                p=re.match(r'^\s*\\_(\w+): \(([^)]*)\)',lines[j+1]);  par=p.group(1) if p else None
            if ind2==ind+2 and s2=='|vpiActual:':
                a=re.match(r'^(\s*)\\_(\w+): \(([^)]*)\)',lines[j+1])
                if a and len(a.group(1))==ind+2: act=a.group(2)+' '+a.group(3)
            j+=1
        if nm in NAMES: out[(dec,span)]=(nm,par,act)
    return out
g=scan(sys.argv[1]); o=scan(sys.argv[2])
allk=sorted(set(g)|set(o), key=lambda t:(int(t[1].split(':')[0]),int(t[1].split(':')[1].split('-')[0])))
print("%-4s %-72s %-16s | %-24s %-24s"%('','key(decompile,span)','parent','GOLDEN actual','OURS actual'))
dis=0
for k in allk:
    G=g.get(k); O=o.get(k)
    ga=G[2] if G else 'ABSENT'; oa=O[2] if O else 'ABSENT'
    par=(G or O)[1]
    mark='   ' if ga==oa else '***'
    if ga!=oa: dis+=1
    print("%s %-72s %-16s | %-24s %-24s"%(mark,str(k),par,ga,oa))
print("total keys=%d  disagreeing=%d"%(len(allk),dis))
