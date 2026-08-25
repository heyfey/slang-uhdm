#!/usr/bin/env python3
"""r10v150 per-cell scorer with DISTANCE.  Judge language (no VpiParent, no
VpiFullName in either form, no VpiFile, no ids).  dist = number of lines in the
unified diff of the cell against GOLDEN (0 = byte-identical to golden).
Verdicts: RIGHT / FIXED / BROKEN / UNMOVED / TOWARD / AWAY / SIDEWAYS."""
import sys,os,difflib
src=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'score2.py')).read()
src=src[:src.rindex('\nmain()')]
ns={}; exec(compile(src,'score2','exec'),ns)
load,cells=ns['load'],ns['cells']
d=sys.argv[1]; pat=sys.argv[2]
sfx='e' if os.environ.get('VIEW')=='elab' else ''
g=load(os.path.join(d,'g%s.dump'%sfx),d); o=load(os.path.join(d,'o%s.dump'%sfx),d); q=load(os.path.join(d,'q%s.dump'%sfx),d)
G,O,Q=cells(g,pat),cells(o,pat),cells(q,pat)
def dist(a,b):
    if a is None or b is None: return -1
    return sum(1 for l in difflib.unified_diff(a.split('\n'),b.split('\n'),n=0) if l[:1] in '+-' and l[:3] not in ('+++','---'))
tally={}
for n in sorted(set(G)|set(O)|set(Q)):
    gg,oo,qq=G.get(n),O.get(n),Q.get(n)
    if gg is None: v='NOGOLDEN'; do=dq=-1
    else:
        do,dq=dist(gg,oo),dist(gg,qq)
        if do==0 and dq==0: v='RIGHT'
        elif do>0 and dq==0: v='FIXED'
        elif do==0 and dq>0: v='BROKEN'
        elif oo==qq: v='UNMOVED'
        elif dq<do: v='TOWARD'
        elif dq>do: v='AWAY'
        else: v='SIDEWAYS'
    tally[v]=tally.get(v,0)+1
    print('%-10s %-12s do=%d dq=%d'%(v,n,do,dq))
print('-- %s %s %s'%(os.path.basename(d),os.environ.get('VIEW','def'),' '.join('%s=%d'%(k,tally[k]) for k in sorted(tally))))
