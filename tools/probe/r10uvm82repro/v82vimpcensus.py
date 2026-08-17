import re,sys,collections
def parse(path, wd):
    lines=open(path, errors='replace').read().split('\n')
    ind=lambda s: len(s)-len(s.lstrip(' '))
    out=collections.Counter()
    for i,l in enumerate(lines):
        m=re.match(r'^(\s*)\\_(parameter|type_parameter): \(([^)]*)\)(.*)$', l)
        if not m: continue
        base=ind(l); kind=m.group(2); nm=m.group(3); rest=m.group(4)
        span=re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', rest)
        span=span.group(0) if span else '?'
        imported='<EMPTY>'; pkind='?'
        j=i+1
        while j<len(lines):
            l2=lines[j]
            if not l2.strip(): j+=1; continue
            if ind(l2)<=base: break
            if ind(l2)==base+2:
                mm=re.match(r'^\s*\|vpiImported:(.*)$', l2)
                if mm: imported=mm.group(1)
                if re.match(r'^\s*\|vpiParent:\s*$', l2) and j+1<len(lines):
                    pm=re.match(r'^\s*\\_(\w+): ?\(?([^),]*)', lines[j+1])
                    if pm: pkind=pm.group(1)+'|'+pm.group(2)
            j+=1
        nm=nm.replace(wd,'WD')
        out[(kind,nm,span,pkind,imported)]+=1
    return out
a=parse(sys.argv[1],sys.argv[3]); b=parse(sys.argv[2],sys.argv[4])
only_g=a-b; only_o=b-a
print("GOLDEN-ONLY (%d):"%sum(only_g.values()))
for k,v in sorted(only_g.items()): print("   G x%d %s"%(v,k))
print("OURS-ONLY (%d):"%sum(only_o.values()))
for k,v in sorted(only_o.items()): print("   O x%d %s"%(v,k))
