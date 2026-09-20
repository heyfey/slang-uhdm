#!/usr/bin/env python3
"""r11u68 BAIL READER — print, per detector row, whether GOLDEN's walk bailed
at operand 0 (the two controls keep their own 64) or completed (the controls
carry the 8-bit member width), beside the same row on our binary.
usage: bail68.py <golden.dump> <ours.dump> [sect]"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape68 as shape
SECT = 'uhdmtopModules'
def rows(p):
    return {n: d.split('ops=[',1)[1].rstrip(']').split()
            for s,n,l,d in shape.parse(p) if s==SECT and d.startswith('op=75 ') and 'ops=[' in d}
def sz(c): return c.split('/')[1].split('@')[0] if c.startswith('const/') else '-'
g, o = rows(sys.argv[1]), rows(sys.argv[2])
if not g: sys.stderr.write('NO ELABORATED op75 ROW IN GOLDEN — reader blind\n'); sys.exit(4)
nb=nk=0
for k in sorted(g, key=lambda x: list(g).index(x)):
    go, oo = g[k], o.get(k, [])
    gb = 'BAIL' if len(go)>1 and sz(go[1])!='8' else 'ok'
    ob = 'BAIL' if len(oo)>1 and sz(oo[1])!='8' else 'ok'
    if gb=='BAIL': nb+=1
    ok = (gb==ob)
    nk += ok
    print('%-9s G=%-4s O=%-4s %s  gold[%s]  ours[%s]' %
          (k.split('.')[-1], gb, ob, 'AGREE' if ok else 'DIFF ', ' '.join(go), ' '.join(oo)))
print('ROWS %d  GOLDEN-BAILS %d  AGREE %d  DIFF %d' % (len(g), nb, nk, len(g)-nk))
