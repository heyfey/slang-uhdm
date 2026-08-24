#!/usr/bin/env python3
# cells32v.py <golden.dump> <pris.dump> <pat.dump> -- view-general multiset of
# SCOPED-CALL-family objects, keyed on (kind, line:col-endln, last two "::"
# segments of the printed name).  Fullname prefixes differ between producers by
# design, so only the tail is keyed.  Counts are MULTISET counts.
import re,sys,collections
KINDS=('func_call','task_call','method_func_call','ref_obj')
pat=re.compile(r'\\_(%s): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)'%'|'.join(KINDS))
def load(p):
    c=collections.Counter()
    for ln in open(p,errors='replace'):
        m=pat.search(ln)
        if not m: continue
        kind,name,l,col,el,ec=m.groups()
        segs=name.split('::')
        tail='::'.join(segs[-2:]) if len(segs)>1 else name
        if '::' not in tail: continue          # only the scoped family
        c[(kind,tail,f'{l}:{col}-{el}:{ec}')]+=1
    return c
g,o,p=[load(x) for x in sys.argv[1:4]]
keys=sorted(set(g)|set(o)|set(p),key=lambda k:(int(k[2].split(':')[0]),k[2],k[0],k[1]))
print(f"{'line-span':22} {'kind':18} {'name':34} {'G':>3} {'PRIS':>4} {'PAT':>4}  verdict")
tog=awy=same_ok=same_bad=0
for k in keys:
    kind,tail,span=k
    a,b,c=g[k],o[k],p[k]
    if a==b==c: v='='
    elif b!=c:
        if c==a and b!=a: v='TO-GOLDEN'; tog+=1
        elif b==a and c!=a: v='AWAY-GOLDEN'; awy+=1
        else: v='CHANGED'
    else:
        v='still-differs' if a!=b else '='
    if v!='=':
        print(f"{span:22} {kind:18} {tail:34} {a:3} {b:4} {c:4}  {v}")
print(f"-- TO-GOLDEN keys={tog} AWAY-GOLDEN keys={awy}")
