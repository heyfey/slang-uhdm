#!/usr/bin/env python3
"""Three-way slot score: golden vs BASE / shipped-PAT / verifier-VFIX."""
import sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vcen
def load(p):
    d = collections.defaultdict(list)
    for k, pay, sp in vcen.collect(p):
        d[k].append((pay, sp))
    return d
tot = collections.Counter(); bad = []
for c in sys.argv[1:]:
    for v in ('def','elab'):
        g=load('cells/%s/golden_%s.uhdm'%(c,v))
        arms={t:load('cells/%s/ours_%s_%s.uhdm'%(c,t,v)) for t in ('BASE','PAT','VFIX')}
        r=collections.Counter()
        for k in sorted(set(g)|set().union(*[set(a) for a in arms.values()])):
            gg=sorted(x[0] for x in g.get(k,[]))
            if not gg: 
                r['NOGOLD']+=1; continue
            b=sorted(x[0] for x in arms['BASE'].get(k,[]))
            p=sorted(x[0] for x in arms['PAT'].get(k,[]))
            f=sorted(x[0] for x in arms['VFIX'].get(k,[]))
            okb,okp,okf = b==gg, p==gg, f==gg
            r['B_ok']+=okb; r['P_ok']+=okp; r['F_ok']+=okf; r['N']+=1
            if okp and not okf: r['REGRESSION_P_to_F']+=1; bad.append(('P->F',c,v,k,gg,p,f))
            if okb and not okf: r['REGRESSION_B_to_F']+=1; bad.append(('B->F',c,v,k,gg,b,f))
            if not okp and okf: r['FIXED_by_verifier']+=1
        print('%-9s %-5s N=%-4d BASE_ok=%-4d PAT_ok=%-4d VFIX_ok=%-4d  %s' % (
            c,v,r['N'],r['B_ok'],r['P_ok'],r['F_ok'],
            {k:v2 for k,v2 in r.items() if k.startswith(('REG','FIX'))}))
        for k2,v2 in r.items(): tot[k2]+=v2
print('TOTAL', dict(tot))
for row in bad: print('  !!', row)
