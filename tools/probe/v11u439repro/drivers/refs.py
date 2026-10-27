import sys,re
# list every ref_obj with its location and whether it carries a vpiActual (and of what)
L=open(sys.argv[1]).read().split('\n')
for i,l in enumerate(L):
    m=re.match(r'^(\s*)\\_ref_obj: \(([^)]*)\), line:(\d+:\d+)',l)
    if not m: continue
    ind=len(m.group(1)); act='-'
    for j in range(i+1,len(L)):
        l2=L[j]
        ind2=len(l2)-len(l2.lstrip())
        if l2.strip().startswith('\\_') and ind2<=ind: break
        if l2.strip()=='|vpiActual:' and ind2==ind+2:
            act=L[j+1].strip(); break
    print(m.group(3), m.group(2), '->', act)
