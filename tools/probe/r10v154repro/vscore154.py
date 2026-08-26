#!/usr/bin/env python3
import sys, collections
def load(p):
    d = collections.defaultdict(set); cnt = collections.Counter()
    try: txt = open(p).read().split('\n')
    except Exception: return None, None
    if txt and txt[0].startswith(('SURELOG_FAIL','SLANG_REJECT')): return None, None
    for ln in txt:
        if not ln.strip(): continue
        f = ln.split('\t')
        if len(f) < 7: continue
        o,n,s,v,dec,sz,c = f[:7]
        d[(o,n,s)].add((v,dec,sz)); cnt[(o,n,s)] += int(c)
    return d, cnt
arm = sys.argv[1]; W = sys.argv[2]   # W = 'pat' or 'fix'
g,gc = load(f'{arm}/g.cells'); pr,pc = load(f'{arm}/pris.cells'); pa,ac = load(f'{arm}/{W}.cells')
if g is None or pr is None or pa is None:
    print(f'{arm}\tSKIP'); sys.exit(0)
t = collections.Counter()
for k in sorted(set(g)|set(pr)|set(pa)):
    gv,pv,av = g.get(k,set()), pr.get(k,set()), pa.get(k,set())
    if pv==gv and av==gv: r='still-right'
    elif pv!=gv and av==gv: r='TO-GOLDEN'
    elif pv==gv and av!=gv: r='AWAY-GOLDEN'
    elif pv!=av: r='MOVED-WRONG'
    else: r='still-wrong'
    t[r]+=1
    if r=='AWAY-GOLDEN':
        print(f'  {r}\t{arm.split("/")[-1]}\t{k[1]}\tG={sorted(gv)}\tP={sorted(pv)}\tX={sorted(av)}')
    if pc.get(k)!=ac.get(k):
        print(f'  COUNT-MOVED\t{arm.split("/")[-1]}\t{k[1]}\tpris={pc.get(k)} new={ac.get(k)}')
print(f'{arm}\t' + ' '.join(f'{k}={v}' for k,v in sorted(t.items())))
