import re,sys
def refs(path):
    L=open(path).read().split('\n'); out={}
    for i,ln in enumerate(L):
        m=re.search(r'\\_(ref_obj|part_select|bit_select|indexed_part_select|hier_path): .*?\((.*?)\), line:(\d+):(\d+)',ln)
        if not m or m.group(1)!='ref_obj': continue
        ind=len(ln)-len(ln.lstrip()); act='<none>'
        j=i+1
        while j<len(L):
            s=L[j]; k=len(s)-len(s.lstrip())
            if k<=ind: break
            if s.strip()=='|vpiActual:':
                a=L[j+1].strip()
                mm=re.match(r'\\_(\w+): ?(\w*) ?\((.*?)\), line:(\d+):(\d+)',a) or re.match(r'\\_(\w+): \((.*?)\)',a)
                act=a.split('|')[0].strip()
                break
            j+=1
        key=(m.group(2),m.group(3)+':'+m.group(4))
        out.setdefault(key,[]).append(re.sub(r', id:\d+','',act))
    return out
g=refs(sys.argv[1]); o=refs(sys.argv[2])
n=0
for k in sorted(set(g)|set(o)):
    a,b=g.get(k),o.get(k)
    if a!=b:
        n+=1; print(f"{k[1]:>10} {k[0]}\n     G={a}\n     O={b}")
print("DIFFERING REF KEYS:",n,"of",len(set(g)|set(o)))
