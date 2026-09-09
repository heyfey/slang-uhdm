import sys,re
def sub(path,name):
    L=open(path).read().split('\n')
    best=None
    for i,l in enumerate(L):
        m=re.match(r'^(\s*)\\_interface_inst: \S+ \(%s\)'%re.escape(name),l)
        if not m: continue
        b=len(m.group(1)); j=i+1; blk=[l.strip()]
        while j<len(L):
            if L[j].strip()=='': j+=1; continue
            if len(L[j])-len(L[j].lstrip())<=b: break
            blk.append(L[j][b:]); j+=1
        if best is None or len(blk)>len(best): best=blk
    return best or []
a=sub(sys.argv[1],sys.argv[3]); b=sub(sys.argv[2],sys.argv[3])
import difflib
print("golden=%d ours=%d"%(len(a),len(b)))
for l in difflib.unified_diff(a,b,'golden','ours',lineterm='',n=0): print(l)
