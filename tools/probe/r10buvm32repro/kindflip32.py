#!/usr/bin/env python3
# r10buvm32repro/kindflip32.py — the census join re-keyed WITHOUT the span, so a
# span shift cannot masquerade as a KIND flip.  Classifies every scoped-call cell
# as IDENTICAL / SPAN-ARG-ONLY / MISSING-OURS / EXTRA-OURS / KIND / "CALL->REF"
# (this pass's population).  MEASUREMENT ONLY.
#   kindflip32.py <cen.tsv>
import sys, collections
rows=collections.defaultdict(collections.Counter)
for ln in open(sys.argv[1],errors='replace'):
    f=ln.rstrip('\n').split('\t')
    if len(f)<10 or f[1]!='SCALL': continue
    side,test,mode=f[0].split('|')
    span,kind,name=f[2],f[3],f[4]
    link=f[5][5:];narg=f[6][5:];home=f[7][5:];pos=f[8][4:];reach=f[9][6:]
    if reach!='Y': continue
    # key WITHOUT the span: name + home + start line
    sl=span.split(':')[0]
    rows[(test,mode,side)][(sl,name,home)]+=0
    rows[(test,mode,side)][(sl,name,home,'K',kind)]+=1
    rows[(test,mode,side)][(sl,name,home,'S',kind,span,narg,pos)]+=1
out=collections.Counter()
detail=collections.defaultdict(list)
for (t,m,s) in list(rows):
    if s!='G': continue
    G=rows[(t,m,'G')];O=rows.get((t,m,'O'),collections.Counter())
    cells={k[:3] for k in G if len(k)==3}|{k[:3] for k in O if len(k)==3}
    for c in sorted(cells):
        gk=collections.Counter({k[4]:v for k,v in G.items() if len(k)==5 and k[:3]==c})
        ok=collections.Counter({k[4]:v for k,v in O.items() if len(k)==5 and k[:3]==c})
        gs={k[4:] for k in G if len(k)==7 and k[:3]==c}
        os_={k[4:] for k in O if len(k)==7 and k[:3]==c}
        if gk==ok:
            if gs==os_: out['IDENTICAL']+=1
            else: out['SPAN/ARG-ONLY']+=1; detail['SPAN/ARG-ONLY'].append((t,m,c,sorted(gs),sorted(os_)))
        else:
            cls='KIND'
            if not ok: cls='MISSING-OURS'
            elif not gk: cls='EXTRA-OURS'
            elif set(gk)=={'ref_obj'} and set(ok)&{'func_call','task_call'}: cls='CALL->REF (this pass)'
            out[cls]+=1; detail[cls].append((t,m,c,dict(gk),dict(ok),sorted(gs),sorted(os_)))
print(dict(out))
for k in ['CALL->REF (this pass)','MISSING-OURS','EXTRA-OURS','KIND']:
    print(f"--- {k}: {len(detail[k])}")
    for d in detail[k][:40]: print("   ",d)
