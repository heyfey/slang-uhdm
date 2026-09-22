import re,sys,collections
# location-keyed constant scorer: key = (line:col) of the constant, value = (val, ct, size)
def read(p):
    res=collections.defaultdict(list)
    L=open(p,errors='replace').read().split('\n')
    for i,l in enumerate(L):
        m=re.match(r'\s*\\_constant: .*line:(\d+):(\d+), endln:(\d+):(\d+)',l)
        if not m: continue
        blk='\n'.join(L[i+1:i+8])
        v=re.search(r'\|((?:INT|UINT|HEX|BIN|DEC|OCT|REAL|STRING):\S*)',blk)
        c=re.search(r'\|vpiConstType:(\d+)',blk)
        s=re.search(r'\|vpiSize:(\d+)',blk)
        res[(m.group(1),m.group(2),m.group(3),m.group(4))].append(
            (v.group(1) if v else '?', c.group(1) if c else '?', s.group(1) if s else '?'))
    return {k:sorted(v) for k,v in res.items()}
g,a,b=(read(x) for x in sys.argv[1:4])
TO=AWAY=STILL=EQ=MW=0; ex=[]
for k in sorted(set(g)&set(a)&set(b)):
    for f in range(3):
        gv=sorted(x[f] for x in g[k]); av=sorted(x[f] for x in a[k]); bv=sorted(x[f] for x in b[k])
        if len(gv)!=len(av) or len(av)!=len(bv): continue
        ag,bg = av==gv, bv==gv
        if ag and bg: EQ+=1
        elif bg: TO+=1
        elif ag:
            AWAY+=1; ex.append(('AWAY',k,f,gv,av,bv))
        else:
            STILL+=1
            if av!=bv: MW+=1; ex.append(('MWRONG',k,f,gv,av,bv))
print(f'  LOC-KEYED  TO={TO} AWAY={AWAY} STILL={STILL} EQ={EQ} MWRONG={MW} keys={len(set(g)&set(a)&set(b))}')
for e in ex[:8]: print('   ',e)
