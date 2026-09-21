#!/usr/bin/env python3
"""r11u76 arm lister — the DEC-aware shape lister's topModules op75 rows,
golden beside one binary, cell by cell.  usage: list76.py <arm> <tag> [griddir]"""
import importlib.util, os, re, sys
here=os.path.dirname(os.path.abspath(__file__))
spec=importlib.util.spec_from_file_location('shape', os.path.join(here,'shape.py'))
sh=importlib.util.module_from_spec(spec); spec.loader.exec_module(sh)
arm, tag = sys.argv[1], sys.argv[2]
gd = sys.argv[3] if len(sys.argv)>3 else os.path.join(here,'grid')
def rows(p):
    out={}
    seen={}
    for sect,name,loc,d in sh.parse(p):
        if sect!='uhdmtopModules' or not d.startswith('op='): continue
        m=re.search(r'ops=\[(.*)\]$',d)
        k=name; n=seen.get(k,0); seen[k]=n+1
        out[(name,n)]=m.group(1).split() if m.group(1) else []
    return out
G=rows(os.path.join(gd,'%s.g.dump'%arm)); P=rows(os.path.join(gd,'%s.%s.dump'%(arm,tag)))
for k in sorted(set(G)|set(P)):
    g=G.get(k,[]); p=P.get(k,[])
    for i in range(max(len(g),len(p))):
        gv=g[i] if i<len(g) else '<absent>'; pv=p[i] if i<len(p) else '<absent>'
        print('%-34s op%-2d %-32s %-32s %s'%(k[0],i,gv,pv,'' if gv==pv else '  <<<'))
