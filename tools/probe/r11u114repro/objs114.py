#!/usr/bin/env python3
# (r11u114) objs114.py <dump> [minline maxline]: deduped cell lister used for the grid tables.
# objs.py <dump> [minline maxline]: deduped (section, kind, name, span, direct props) of every object printed with a body
import sys,re
L=open(sys.argv[1],errors='replace').read().split('\n')
lo=int(sys.argv[2]) if len(sys.argv)>2 else 0; hi=int(sys.argv[3]) if len(sys.argv)>3 else 10**9
sec='HDR'; seen=set()
KEEP=re.compile(r'^\|(UINT|INT|BIN|HEX|DEC|OCT|STRING|vpiSize|vpiName|vpiDecompile|vpiConstType|vpiOpType|vpiFullName)')
for i,l in enumerate(L):
    for k,v in (('|uhdmallModules','DEF'),('|uhdmtopModules','TOP'),('|uhdmallPackages','PKGDEF'),('|uhdmtopPackages','PKGTOP'),('|uhdmallClasses','CLS'),('|uhdmallInterfaces','IFDEF')):
        if l.startswith(k): sec=v
    m=re.match(r'^(\s*)\\_(\w+): (.*?)(?:, id:\d+)?(?:, file:[^,]*)?, line:(\d+):(\d+), endln:(\d+):(\d+)',l)
    if not m: continue
    ind=len(m.group(1)); ln=int(m.group(4))
    if ln<lo or ln>hi: continue
    props=[]; j=i+1
    while j<len(L):
        s=L[j]; si=len(s)-len(s.lstrip())
        if si<=ind: break
        if si==ind+2 and KEEP.match(s.strip()): props.append(s.strip())
        if si==ind+2 and s.strip() in ('|vpiActual:','|vpiParent:'):
            nx=L[j+1].strip() if j+1<len(L) else ''
            props.append(s.strip()[1:-1]+'='+re.sub(r', id:\d+','',nx)[:70])
        j+=1
    if j==i+1: continue
    key=(sec,m.group(2),re.sub(r'\s+$','',m.group(3)),'%s:%s-%s:%s'%m.group(4,5,6,7),' '.join(props))
    if key in seen: continue
    seen.add(key); print(' | '.join(key))
