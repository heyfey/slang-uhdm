#!/usr/bin/env python3
"""r11u79 OBJECT-BLOCK COMPARATOR — one block per top-level object in a
section, normalised for SPANS (never compared) and diffed golden vs ours."""
import re,sys,collections
SPAN=re.compile(r",? ?(file:[^,]*|line:\d+:\d+|endln:\d+:\d+)")
def blocks(fn,sect):
    L=open(fn,errors='replace').read().splitlines()
    cur='?'; cure=None; out=collections.OrderedDict()
    name=None; buf=[]
    for l in L:
        m=re.match(r"^\|(uhdm\w+|weaklyReferenced\w*):",l)
        if m:
            if name: out.setdefault(name,[]).append(buf)
            name=None; buf=[]; cur=m.group(1); continue
        if cur!=sect: continue
        ind=len(l)-len(l.lstrip(' '))
        if ind<=2 and l.lstrip().startswith('\\_'):
            if name: out.setdefault(name,[]).append(buf)
            mo=re.match(r"\s*\\_(\w+):\s*(\([^)]*\))?",l)
            k=mo.group(1); n=(mo.group(2) or '').strip('()')
            name="%s"%n if n else k
            buf=[SPAN.sub("",l)]
            continue
        if name is not None: buf.append(SPAN.sub("",l))
    if name: out.setdefault(name,[]).append(buf)
    return out
g=blocks(sys.argv[1],sys.argv[3] if len(sys.argv)>3 else 'uhdmtopModules')
o=blocks(sys.argv[2],sys.argv[3] if len(sys.argv)>3 else 'uhdmtopModules')
bad=0
for n in sorted(set(g)|set(o)):
    gb=["\n".join(b) for b in g.get(n,[])]; ob=["\n".join(b) for b in o.get(n,[])]
    if sorted(gb)==sorted(ob): continue
    bad+=1
    gk=[b[0].strip()[2:].split(':')[0] for b in g.get(n,[])]
    ok=[b[0].strip()[2:].split(':')[0] for b in o.get(n,[])]
    print("!! %-28s GOLD %-30s OURS %s" % (n, ",".join(gk) or '<none>', ",".join(ok) or '<none>'))
print("DIFFERING_BLOCKS=%d TOTAL=%d"%(bad,len(set(g)|set(o))))
