import re,sys
def refs(path):
    L=open(path).read().split('\n'); out=[]
    for i,ln in enumerate(L):
        m=re.search(r'\\_ref_obj: \((.*?)\), line:(\d+):(\d+)',ln)
        if not m: continue
        ind=len(ln)-len(ln.lstrip()); act='<none>'
        j=i+1
        while j<len(L):
            s=L[j]; k=len(s)-len(s.lstrip())
            if k<=ind: break
            if s.strip()=='|vpiActual:':
                act=re.sub(r', id:\d+','',L[j+1].strip()); break
            j+=1
        out.append((m.group(1),m.group(2)+':'+m.group(3),act))
    return out
for t,p in (('G',sys.argv[1]),('O',sys.argv[2])):
    print(' --',t)
    for n,l,a in refs(p): print(f"   {l:>7} {n:40s} {a}")
