# r11u128: one evidence file per wanted cluster (args: <work> <out dir> <cluster ids...>)
import os as _os, sys as _sys
_sys.path.insert(0, _os.path.dirname(_os.path.abspath(__file__)))
from common import rekey
import json,sys,os
W=sys.argv[1]; OUT=sys.argv[2]; WANT=set(sys.argv[3:])
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from analyze import load, parents, chain
ids=json.load(open(f'{W}/ids.json')); cid=ids['cid']
R=[json.loads(l) for l in open(f'{W}/corpus.jsonl')]
RP=[json.loads(l) for l in open(f'{W}/probe.jsonl')]
for r in R: r['_d']=f"/tmp/r11u128_dumps/{r['corpus']}/{r['mode']}/{r['test']}"
for r in RP: r['_d']=f"/tmp/r11u128_pdumps/probe/default/{r['test']}"
want=[c for c in cid if cid[c] in WANT]
for r in R+RP:
    for x in r['rows']: x['cluster']=rekey(x)
best={}
for src in (R, RP):
    for r in src:
        for x in r['rows']:
            c=x['cluster']
            if c in want and not (c in best and best[c][3] is not src):
                cand=(r['nA'],len(r['rows']))
                if c not in best or cand<best[c][0]: best[c]=(cand,r,x,src)
cache={}
for c in want:
    if c not in best: continue
    _,r,x,_s=best[c]
    key=(r['corpus'],r['mode'],r['test'])
    D=r['_d']
    if key not in cache:
        A,B=load(D+'.a'),load(D+'.b'); cache.clear(); cache[key]=(A,B,parents(A),parents(B))
    A,B,pA,pB=cache[key]
    fn=f"{OUT}/{cid[c]}_{r['corpus']}_{r['mode']}_{r['test']}.txt"
    with open(fn,'w') as f:
        f.write(f"cluster {cid[c]}: {c}\nrow: {r['corpus']}/{r['mode']}/{r['test']}  strict={r['strict']}  records golden={r['nA']} ours={r['nB']}\n")
        f.write(f"object: #{x['ia']} (golden) / #{x['ib']} (ours)  type={x['type']} name={x['name']}\n  golden: {x['golden']}\n  ours:   {x['ours']}\n  walk parents: {x['chain']}\n")
        f.write("record fields: depth type name defname fullname file line col endline endcol decompile size value consttype\n")
        for side,idx,Rr,P in (('GOLDEN (A)',x['ia'],A,pA),('OURS (B)',x['ib'],B,pB)):
            if idx<0:
                # show the other side's partner window
                continue
            lo=max(0,idx-12); hi=min(len(Rr),idx+12)
            f.write(f"\n--- {side} records {lo}..{hi-1} ('>' = the object)\n")
            for i in range(lo,hi):
                f.write(('> ' if i==idx else '  ')+f"#{i}\t"+'\t'.join(Rr[i])+'\n')
        if x['ia']<0 or x['ib']<0:
            # the other side: window at the same holder position (the parent's partner by content)
            idx = x['ia'] if x['ia']>=0 else x['ib']
            Rr,other = (A,B) if x['ia']>=0 else (B,A)
            P = pA if x['ia']>=0 else pB
            par = P[idx]
            # find the parent's record in the other side by exact fields
            sig = Rr[par] if par>=0 else None
            cand=[i for i,rr in enumerate(other) if sig is not None and rr==sig]
            f.write(f"\n--- the holder {'#'+str(par)} in the other side: exact-record matches at {cand[:5]}\n")
            for j in cand[:1]:
                lo=max(0,j-4); hi=min(len(other),j+14)
                for i in range(lo,hi): f.write(('> ' if i==j else '  ')+f"#{i}\t"+'\t'.join(other[i])+'\n')
        f.write(f"\nall facets of this row ({len(r['rows'])}):\n")
        for y in r['rows'][:40]:
            f.write(f"  {cid[y['cluster']]} #{y['ia']}/{y['ib']} {y['type']} {y['name']} G[{y['golden'][:80]}] O[{y['ours'][:80]}]\n")
        if len(r['rows'])>40: f.write(f"  ... {len(r['rows'])-40} more\n")
    print(fn)
