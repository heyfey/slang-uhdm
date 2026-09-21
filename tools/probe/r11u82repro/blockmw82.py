"""r11v82 PER-BLOCK moved-wrong scan.  Run from the grid directory; the
second tag defaults to `vfix`.  NOTE: this instrument is BLIND BELOW THE
BLOCK -- see README §V6 -- `cellmw82.sh` is the arbiter."""
import sys, os, re, collections
SPAN=re.compile(r",? ?(file:[^,]*|line:\d+:\d+|endln:\d+:\d+)")
def blocks(fn,sect):
    L=open(fn,errors='replace').read().splitlines()
    cur='?'; out=collections.OrderedDict(); name=None; buf=[]
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
            buf=[SPAN.sub("",l)]; continue
        if name is not None: buf.append(SPAN.sub("",l))
    if name: out.setdefault(name,[]).append(buf)
    return out
TAG = sys.argv[1] if len(sys.argv) > 1 else 'vfix'
SECTS=['uhdmallPackages','uhdmtopPackages','uhdmallModules','uhdmtopModules',
       'uhdmallInterfaces','weaklyReferenced']
arms=sorted(d for d in os.listdir('.') if os.path.isdir(d))
mw=0; conv=0; tot=0
for a in arms:
    g=f'{a}/gold.pris.dump'; op=f'{a}/ours.pris.dump'
    g2=f'{a}/gold.{TAG}.dump'; oq=f'{a}/ours.{TAG}.dump'
    if not all(os.path.exists(x) for x in (g,op,g2,oq)): print("SKIP",a); continue
    for S in SECTS:
        G=blocks(g,S); OP=blocks(op,S); G2=blocks(g2,S); OQ=blocks(oq,S)
        for n in set(G)|set(OP)|set(G2)|set(OQ):
            tot+=1
            okp = sorted("\n".join(b) for b in G.get(n,[])) == sorted("\n".join(b) for b in OP.get(n,[]))
            okq = sorted("\n".join(b) for b in G2.get(n,[])) == sorted("\n".join(b) for b in OQ.get(n,[]))
            if okp and not okq:
                mw+=1; print(f"MOVED-WRONG {a}/{S}/{n}")
            if okq and not okp:
                conv+=1; print(f"CONVERTED   {a}/{S}/{n}")
print(f"MOVED-WRONG={mw} CONVERTED={conv} BLOCKS={tot} ARMS={len(arms)}")
