import sys,re
# refbind.py dump name: per ref_obj with name, print loc and actual kind (or NONE)
lines=open(sys.argv[1]).read().split('\n'); nm=sys.argv[2]
for i,l in enumerate(lines):
    m=re.match(r'^(\s*)\\_ref_obj: \(([^)]*)\)(.*)',l)
    if not m or not m.group(2).endswith('.'+nm) and m.group(2)!=nm: continue
    ind=len(m.group(1)); act='NONE'
    for j in range(i+1,min(i+40,len(lines))):
        s=lines[j]; k=len(s)-len(s.lstrip())
        if s.lstrip().startswith('\\_') and k<=ind: break
        if s.strip()=='|vpiActual:':
            act=lines[j+1].strip()[:60]; break
    print(m.group(2),m.group(3).strip()[:30],act)
