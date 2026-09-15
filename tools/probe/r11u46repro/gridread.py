# view-aware SHAPE LISTER: counts $signed/$unsigned sys_func_call objects per
# source cell, split by DEF view (uhdmallModules) and ELAB view (uhdmtopModules).
import re,sys,collections
def cells(path):
    view='DEF'; c=collections.Counter(); seen=set()
    for ln in open(path,errors='replace'):
        if '|uhdmtopModules:' in ln: view='ELAB'
        m=re.search(r'\\_sys_func_call: \(\$(signed|unsigned)\), line:(\d+):(\d+)',ln)
        if m: c[(int(m.group(2)),int(m.group(3)),m.group(1),view)]+=1
    # a dump prints each object twice (once as the child, once as the back-ref)
    return {k:v//2 if v%2==0 else v for k,v in c.items()}
g=cells(sys.argv[1]); o=cells(sys.argv[2])
keys=sorted(set(g)|set(o))
diff=0
print("%-26s %6s %6s"%("line:col:kind:view","GOLD","OURS"))
for k in keys:
    gv,ov=g.get(k,0),o.get(k,0)
    flag="" if gv==ov else ("  <== MISSING-OURS" if ov<gv else "  <== EXTRA-OURS")
    if gv!=ov: diff+=1
    print("%-26s %6d %6d%s"%("%d:%d:%s:%s"%k,gv,ov,flag))
print("CELLS-DIFF %d / %d"%(diff,len(keys)))
