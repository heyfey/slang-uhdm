#!/usr/bin/env python3
"""r11u68 SIZE-HALF CELL LISTER — for each elaborated op75 row, print the cells
whose vpiSize differs between golden and ours, with the whole cell so the
encoding half is visible beside it.  Calibrate golden-vs-golden first.
usage: szdiff68.py <golden.dump> <ours.dump> [arm]"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape68 as shape
ELAB = ('uhdmtopModules','uhdmtopPackages','uhdmtopInterfaces',
        'uhdmallModules','uhdmallPackages','uhdmallInterfaces')
def rows(p):
    return {(s,n): d.split('ops=[',1)[1].rstrip(']').split()
            for s,n,l,d in shape.parse(p)
            if s in ELAB and d.startswith('op=75 ') and n!='?' and 'ops=[' in d}
def sz(c): return c.split('/')[1].split('@')[0] if c.startswith('const/') else '-'
g,o = rows(sys.argv[1]), rows(sys.argv[2])
arm = sys.argv[3] if len(sys.argv)>3 else ''
if not g: sys.stderr.write('NO ELABORATED op75 ROW IN GOLDEN — lister blind\n'); sys.exit(4)
tot=same=diff=absent=0
for k in sorted(g):
    gc=g[k]; oc=o.get(k)
    if oc is None:
        absent+=len(gc); continue
    for i in range(len(gc)):
        tot+=1
        ov = oc[i] if i<len(oc) else '<none>'
        if sz(gc[i])==sz(ov): same+=1
        else:
            diff+=1
            print('  SZDIFF %-16s %-30s op%-2d golden=%-32s ours=%s' % (k[0],k[1],i,gc[i],ov))
print('ARM %s SIZE-CELLS %d SAME %d SZDIFF %d ABSENT %d' % (arm, tot, same, diff, absent))
