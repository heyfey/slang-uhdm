#!/usr/bin/env python3
"""judge.py <casekeydir> <P cfg> <L cfg>: field-level verdict of L (law on) against P (law off), golden the arbiter.
SAME | TURNED | BREAK:eq->ne | BREAK:judge | WORSE:<fields> (a field golden matched under P differs under L,
on records aligned in golden/P/L) | GROW:<fields> (per-field count grows) | OK:<better>/<same> | STAGE1:<cmpP>-><cmpL>"""
import sys, os, json
wd,P,L=sys.argv[1:4]
N=['depth','type','name','defname','fullname','file','line','col','endline','endcol','decompile','size','value','consttype']
def rl(p): return open(p).read().split('\n')[:-1] if os.path.exists(p) else None
def ds(p):
    if not os.path.exists(p): return None
    return {tuple(map(int,l.split())) for l in open(p) if l.strip()}
up=lambda p: open(p,'rb').read() if os.path.exists(p) else None
pb,lb=up(f'{wd}/{P}.uhdm'),up(f'{wd}/{L}.uhdm')
if pb is None or lb is None: print('NODB', 'P' if pb is None else '', 'L' if lb is None else ''); sys.exit()
if pb==lb: print('SAME'); sys.exit()
gp,gl,rp,rl_=rl(f'{wd}/g_{P}.rec'),rl(f'{wd}/g_{L}.rec'),rl(f'{wd}/{P}.rec'),rl(f'{wd}/{L}.rec')
if rp is None and rl_ is None: print('STAGE1-both'); sys.exit()
if rp is not None and rl_ is None: print('BREAK:judge (P judge-equal, L stage1)'); sys.exit()
if rp is None: print('TURNED-judge (P stage1, L judge-equal)'); sys.exit()
dP,dL=ds(f'{wd}/{P}.diffs'),ds(f'{wd}/{L}.diffs')
eqP=not dP and len(gp)==len(rp); eqL=not dL and len(gl)==len(rl_)
m=min(len(gp),len(gl),len(rp),len(rl_))
for i in range(m):
    a=rp[i].split('\t'); b=rl_[i].split('\t')
    if gp[i]!=gl[i] or a[:2]!=b[:2]: m=i; break
worse=sorted(x for x in dL if x[0]<m and x not in dP)
better=sorted(x for x in dP if x[0]<m and x not in dL)
def tally(d):
    t={}
    for i,k in d: t[N[k]]=t.get(N[k],0)+1
    return t
tP,tL=tally(dP),tally(dL)
grow=[f'{k}:{tP.get(k,0)}->{v}' for k,v in tL.items() if v>tP.get(k,0)]
info=f'P={tP}{"" if len(gp)==len(rp) else " len%d/%d"%(len(gp),len(rp))} L={tL}{"" if len(gl)==len(rl_) else " len%d/%d"%(len(gl),len(rl_))} aligned={m}'
if eqL and not eqP: v='TURNED'
elif eqP and not eqL: v='BREAK:eq->ne'
elif eqP and eqL: v='EQUAL-both(bytes moved)'
elif worse: v='WORSE:'+','.join(sorted({N[k] for _,k in worse}))+f'({len(worse)})'
elif grow: v='GROW:'+','.join(grow)
else: v=f'OK:better={len(better)}'
print(v, info, ('W@'+';'.join(f'{i}:{N[k]}' for i,k in worse[:4])) if worse else '')
