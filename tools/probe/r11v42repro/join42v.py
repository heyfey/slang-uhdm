import re,sys,collections
arm,gp,pp,qp=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
rx=re.compile(r'\\_(hier_path|bit_select|var_select|part_select|indexed_part_select): \((.*)\),(?: id:\d+,)? line:(\d+):(\d+), endln:(\d+):(\d+)')
def names(p):
    d=collections.defaultdict(set)
    for ln in open(p,errors='replace'):
        m=rx.search(ln)
        if not m: continue
        kind,nm,l,c=m.group(1),m.group(2),int(m.group(3)),int(m.group(4))
        d[(l,c,kind)].add(nm)
    return d
G,P,Q=names(gp),names(pp),names(qp)
keys=sorted(set(G)|set(P)|set(Q))
stats=collections.Counter()
for k in keys:
    g=sorted(G.get(k,[])); p=sorted(P.get(k,[])); q=sorted(Q.get(k,[]))
    sp='SAME' if g==p else 'DIFF'
    sq='SAME' if g==q else 'DIFF'
    verdict=''
    if sp=='SAME' and sq=='DIFF': verdict='*** MOVED-WRONG'; stats['movedwrong']+=1
    elif sp=='DIFF' and sq=='SAME': verdict='FIXED'; stats['fixed']+=1
    elif sp=='DIFF' and sq=='DIFF' and p!=q: verdict='MOVED-AWAY-STILL-WRONG'; stats['moved_away']+=1
    stats['pris_'+sp.lower()]+=1; stats['pat_'+sq.lower()]+=1
    print(f"{arm} {k[0]}:{k[1]} {k[2]:<9} GOLD {'|'.join(g) or '<none>':<34} PRIS {'|'.join(p) or '<none>':<34} PAT {'|'.join(q) or '<none>':<34} {verdict}")
print(f"ARM {arm} SUMMARY cells={len(keys)} PRIS_SAME={stats['pris_same']} PRIS_DIFF={stats['pris_diff']} PAT_SAME={stats['pat_same']} PAT_DIFF={stats['pat_diff']} FIXED={stats['fixed']} MOVED-WRONG={stats['movedwrong']} MOVED-AWAY-STILL-WRONG={stats['moved_away']}")
