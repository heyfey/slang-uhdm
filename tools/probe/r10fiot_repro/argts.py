import re, sys
def scan(path,tag):
    lines=open(path).read().split('\n')
    mod='?'; seen=set(); out=[]
    for i,l in enumerate(lines):
        m=re.match(r'\\_module_inst: (work@\w+)',l)
        if m: mod=m.group(1)
        m=re.search(r'\\_func_call: \((\w+)\)',l)
        if not m: continue
        key=(mod,m.group(1))
        if key in seen: continue
        seen.add(key)
        depth=len(l)-len(l.lstrip())
        args=[]
        j=i+1
        while j<len(lines):
            d=len(lines[j])-len(lines[j].lstrip())
            if lines[j].strip() and d<=depth: break
            if lines[j].strip()=='|vpiArgument:':
                ad=len(lines[j+1])-len(lines[j+1].lstrip())
                kind=lines[j+1].strip().split(':')[0].replace('\\_','')
                ts=False
                k=j+2
                while k<len(lines):
                    dk=len(lines[k])-len(lines[k].lstrip())
                    if lines[k].strip() and dk<=ad: break
                    if lines[k].strip()=='|vpiTypespec:' and dk==ad+2: ts=True
                    k+=1
                args.append((kind,ts))
            j+=1
        out.append((key,args))
    return out
g=dict(scan(sys.argv[1],'G')); o=dict(scan(sys.argv[2],'O'))
for k in sorted(g):
    if g[k]!=o.get(k):
        print('MISMATCH',k,'G',g[k],'O',o.get(k))
    else:
        print('ok      ',k,g[k])
