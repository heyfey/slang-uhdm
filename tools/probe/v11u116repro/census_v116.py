#!/usr/bin/env python3
"""v11u116_census.py <dir>... : each dir holds gold.uhdm + pris.uhdm. Counts law-shaped
cells (golden vs pristine), keyed per cell:
 C1 golden constant non-UINT ct, ours constant UINT ct 9 same size (F1)
 C2 golden ref_obj w/ vpiActual=enum_const, ours constant (F2)
 C3 golden ref_obj w/o actual, ours constant (R1)
 C4 golden constant w/ typespec, ours same constant w/o typespec (R3)"""
import sys, importlib.util, os
CELLS=os.path.join(os.path.dirname(os.path.abspath(__file__)),'cells_v116.py')
src=open(CELLS).read().split('root=sys.argv[1]')[0]
ns={}; exec(src, ns)
def cls(g,p):
    out=[]
    for a in set(g):
        for b in set(p):
            if a==b: continue
            if a.startswith('constant{') and b.startswith('constant{') and '|vpiConstType:9' in b and '|vpiConstType:9' not in a:
                sa=[x for x in a.split(' ') if x.startswith('|vpiSize')]; sb=[x for x in b.split(' ') if x.startswith('|vpiSize')]
                if sa==sb: out.append('C1')
            if a.startswith('ref_obj{') and 'vpiActual=enum_const' in a and b.startswith('constant{'): out.append('C2')
            if a.startswith('ref_obj{') and 'vpiActual=' not in a and b.startswith('constant{'): out.append('C3')
            if a.startswith('constant{') and b.startswith('constant{') and 'vpiTypespec=' in a and 'vpiTypespec=' not in b and a.replace(' '+[x for x in a.split(' ') if x.startswith('vpiTypespec=')][0],'')==b: out.append('C4')
    return out
for d in sys.argv[1:]:
    G=ns['objs'](ns['dump'](os.path.join(d,'gold.uhdm'))); P=ns['objs'](ns['dump'](os.path.join(d,'pris.uhdm')))
    tot={}
    for k in set(G)|set(P):
        g=G.get(k,[]); p=P.get(k,[])
        if g==p: continue
        for c in set(cls(g,p)): tot[c]=tot.get(c,0)+1
    print(os.path.basename(d.rstrip('/')), ' '.join('%s=%d'%(c,tot.get(c,0)) for c in ('C1','C2','C3','C4')))
