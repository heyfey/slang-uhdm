#!/usr/bin/env python3
# r10v117 verifier — arm scorer.  golden vs pristine vs patched, NET and REF
# families, as MULTISETS.  TO-GOLDEN / AWAY-GOLDEN / STILL per slot.
import sys, collections
def load(p):
    nets=collections.Counter(); refs={}; rv=set()
    for ln in open(p):
        f=ln.rstrip('\n').split('\t')
        if len(f)<3: continue
        if f[1]=='NET':
            # tag NET view IMPL owner span name kind nettype
            nets[(f[2],f[4],f[6],f[3])]+=1
        elif f[1]=='REF':
            # tag REF view oob home owner span name actkind actnm par parnm actimpl newlhs
            refs[(f[2],f[5],f[6],f[7])]=(f[8],f[12])
        elif f[1]=='RV':
            rv.add((f[2],f[5],f[6]))
    return nets,refs,rv
g,gr,grv=load(sys.argv[1]); a,ar,arv=load(sys.argv[2]); b,br,brv=load(sys.argv[3])
print("== NET (view, module, name, IMPL/OTH) multiset ==")
keys=sorted(set(g)|set(a)|set(b))
tg=aw=st=0
for k in keys:
    if g[k]==a[k]==b[k]: continue
    verdict=''
    if a[k]!=g[k] and b[k]==g[k]: verdict='TO-GOLDEN'; tg+=1
    elif a[k]==g[k] and b[k]!=g[k]: verdict='AWAY-GOLDEN'; aw+=1
    elif a[k]!=g[k] and b[k]!=g[k]: verdict='STILL'; st+=1
    else: verdict='?'
    print(f"  {verdict:12s} g={g[k]} pris={a[k]} pat={b[k]}  {k}")
print(f"  NET: TO-GOLDEN={tg} AWAY-GOLDEN={aw} STILL={st}")
print("== REF (view, owner, span, name) -> (actual kind, ACTIMPL) ==")
keys=sorted(set(gr)|set(ar)|set(br))
tg=aw=st=miss=0
for k in keys:
    G=gr.get(k); A=ar.get(k); B=br.get(k)
    if G==A==B: continue
    if A is None or B is None or G is None:
        miss+=1; print(f"  KEY-ONLY-SOME g={G} pris={A} pat={B}  {k}"); continue
    if A!=G and B==G: v='TO-GOLDEN'; tg+=1
    elif A==G and B!=G: v='AWAY-GOLDEN'; aw+=1
    elif A!=G and B!=G and A==B: v='STILL'; st+=1
    else: v='CHANGED'; st+=1
    print(f"  {v:12s} g={G} pris={A} pat={B}  {k}")
print(f"  REF: TO-GOLDEN={tg} AWAY-GOLDEN={aw} STILL/CHANGED={st} KEY-ONLY-SOME={miss}")
print("== RV declarations (view, owner, name) ==")
print(f"  g={len(grv)} pris={len(arv)} pat={len(brv)}  pris-vs-pat sym-diff={len(arv^brv)}  g-vs-pat sym-diff={len(grv^brv)}")
for k in sorted(grv^brv): print(f"    RVDIFF g={k in grv} pat={k in brv} {k}")
