import re,sys,collections
IND=re.compile(r'^(\s*)(.*)$')
def parse(fn):
    lines=open(fn).read().split('\n')
    ind=[len(l)-len(l.lstrip()) for l in lines]
    out=[]
    for n,l in enumerate(lines):
        m=re.search(r'\\_bit_select: \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)',l)
        if not m: continue
        base=ind[n]
        # find |vpiIndex: at base+2
        k=n+1
        rec=None
        while k<len(lines) and (ind[k]>base or lines[k].strip()==''):
            if lines[k].strip()=='|vpiIndex:':
                # child object on next line
                c=k+1
                cm=re.match(r'\s*\\_(\w+): ?(.*?), line:(\d+):(\d+), endln:(\d+):(\d+)',lines[c])
                if not cm:
                    cm2=re.match(r'\s*\\_(\w+):',lines[c]); rec=(cm2.group(1) if cm2 else '?','','','','','')
                    break
                kind=cm.group(1); span=f"{cm.group(3)}:{cm.group(4)}-{cm.group(5)}:{cm.group(6)}"
                cb=ind[c]; d=c+1; f={}
                while d<len(lines) and ind[d]>cb:
                    s=lines[d].strip()
                    mm=re.match(r'\|(vpiDecompile|vpiSize|vpiConstType|vpiName):(.*)',s)
                    if mm: f[mm.group(1)]=mm.group(2)
                    elif re.match(r'\|(U?INT|BIN|HEX|OCT|DEC|REAL|STRING):',s): f['VAL']=s[1:]
                    d+=1
                rec=(kind,span,f.get('vpiDecompile',''),f.get('vpiSize',''),f.get('vpiConstType',''),f.get('VAL',''))
                break
            k+=1
        if rec is None: rec=('<none>','','','','','')
        out.append((m.group(1),f"{m.group(2)}:{m.group(3)}",f"{m.group(2)}:{m.group(3)}-{m.group(4)}:{m.group(5)}",rec))
    return out
g=parse(sys.argv[1]); o=parse(sys.argv[2])
gd=collections.defaultdict(list); od=collections.defaultdict(list)
for r in g: gd[(r[0],r[1])].append(r)
for r in o: od[(r[0],r[1])].append(r)
same=diff=0
for k in sorted(set(gd)|set(od)):
    G=gd.get(k,[('','','',('MISSING','','','','',''))])[0]
    O=od.get(k,[('','','',('MISSING','','','','',''))])[0]
    gs="%s dec=%r sz=%s ct=%s %s @%s bs@%s"%(G[3][0],G[3][2],G[3][3],G[3][4],G[3][5],G[3][1],G[2])
    os_="%s dec=%r sz=%s ct=%s %s @%s bs@%s"%(O[3][0],O[3][2],O[3][3],O[3][4],O[3][5],O[3][1],O[2])
    if gs==os_: same+=1; 
    else:
        diff+=1
        print("**%-46s\n     G: %s\n     O: %s"%(k[0][:46],gs,os_))
print("SAME=%d DIFF=%d"%(same,diff))
