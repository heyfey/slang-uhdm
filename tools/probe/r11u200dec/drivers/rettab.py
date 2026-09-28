#!/usr/bin/env python3
"""r11u200: per function fN of a case, the golden and ours return variable span and its typespec span (source text).
usage: rettab.py <dut.sv> <golden dump> <ours dump>"""
import re,sys
src=open(sys.argv[1]).read().split('\n')
def tab(p):
    L=open(p).read().split('\n'); out={}
    for i,l in enumerate(L):
        m=re.match(r'^    \\_([a-z_]+_var): \(([^)]*)\), line:(\d+):(\d+), endln:(\d+):(\d+)',l)
        if m and i>0 and 'vpiReturn' in L[i-1]:
            t,n,a,b,c,e=m.group(1),m.group(2),*map(int,m.groups()[2:])
            # typespec: next vpiActual line
            for j in range(i,i+12):
                mm=re.match(r'^\s+\\_([a-z_]+typespec): [^,]*, line:(\d+):(\d+), endln:(\d+):(\d+)',L[j])
                if mm and 'vpiActual' in L[j-1]:
                    ta,tb,tc,te=map(int,mm.groups()[1:]); break
            else: ta=tb=tc=te=0
            out.setdefault(n,(t,src[a-1][b-1:e-1],mm.group(1) if mm else '',src[ta-1][tb-1:te-1] if ta else ''))
    return out
g=tab(sys.argv[2]); o=tab(sys.argv[3])
for k in sorted(g,key=lambda s:int(re.sub(r'\D','',s.split('.')[-1].split('::')[-1]) or 0)):
    print('%-14s %-14s var:%-18r ts:%-16r | ours var:%-18r ts:%r %s'%(k,g[k][0],g[k][1],g[k][3],o.get(k,('','','',''))[1],o.get(k,('','','',''))[3], '' if g[k]==o.get(k) else '<-- DIFF'))
