#!/usr/bin/env python3
"""r11v73 SIZE-AXIS SCORER — the ord66v tuples are (size,constType,value) and
(constType,value); this one scores the SIZE FIELD ALONE, because a cell whose
constType is already wrong can still take its SIZE from RIGHT to WRONG and the
judge reads every field.  usage: sizeaxis.py <g> <p> <l> <arm>"""
import sys, re, os, importlib.util
spec = importlib.util.spec_from_file_location('shape', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'shape.py'))
shape = importlib.util.module_from_spec(spec); spec.loader.exec_module(shape)
def cells(path):
    out={}; seen={}
    for sect,name,loc,d in shape.parse(path):
        if not d.startswith('op='): continue
        m=re.search(r'ops=\[(.*)\]$',d)
        if not m: continue
        ops=m.group(1).split() if m.group(1) else []
        k0=(sect,name,loc); n=seen.get(k0,0); seen[k0]=n+1
        for i,o in enumerate(ops):
            mm=re.match(r'const/([^@]*)@',o)
            out[(sect,name,loc,n,i)]=('const',mm.group(1)) if mm else (o,)
    return out
g,p,l,arm=sys.argv[1:5]
G,P,L=cells(g),cells(p),cells(l)
to=away=still=same=w2=0
for k in sorted(set(G)|set(P)|set(L)):
    gv=G.get(k,'<absent>'); pv=P.get(k,'<absent>'); lv=L.get(k,'<absent>')
    if pv==gv and lv==gv: same+=1
    elif pv==gv and lv!=gv:
        away+=1
        print('  *** SIZE-AWAY %-14s %-24s op%d  G=%s P=%s L=%s'%(k[0],k[1],k[4],gv,pv,lv))
    elif pv!=gv and lv==gv: to+=1
    elif pv==lv: still+=1
    else: w2+=1
print('ARM %-20s SIZE TO=%d AWAY=%d STILL=%d SAME=%d WRONG2=%d'%(arm,to,away,still,same,w2))
