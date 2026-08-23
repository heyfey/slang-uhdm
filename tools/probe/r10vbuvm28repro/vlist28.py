#!/usr/bin/env python3
"""r10vbuvm28 — list every span in a line range across G/PRI/PAT dumps."""
import sys, importlib.util, os
spec = importlib.util.spec_from_file_location('vs', os.path.join(os.path.dirname(os.path.abspath(__file__)),'vscore28.py'))
m = importlib.util.module_from_spec(spec)
src = open(spec.origin).read().replace('main()\n','',1)
exec(compile(src, spec.origin, 'exec'), m.__dict__)
G,P,Q = m.load(sys.argv[1]), m.load(sys.argv[2]), m.load(sys.argv[3])
lo,hi = (int(sys.argv[4]), int(sys.argv[5])) if len(sys.argv)>5 else (0,10**9)
def fmt(c):
    if not c: return '-'
    return ' '.join('%s/%s/%s' % (k[0], k[1] or '.', k[2] or '.') for k in sorted(c))
for k in sorted(set(G)|set(P)|set(Q)):
    if not (lo<=k[0]<=hi): continue
    g,p,q = G.get(k),P.get(k),Q.get(k)
    tag = 'ok ' if (g==p==q) else ('FIX' if (p!=g and q==g) else ('BRK' if (p==g and q!=g) else 'DIF'))
    print('%s %-12s G=%-42s P=%-30s Q=%s' % (tag,'%d:%d-%d'%k, fmt(g), fmt(p), fmt(q)))
