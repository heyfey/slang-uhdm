#!/usr/bin/env python3
"""pairjudge_case.py <casedir> <A_SWITCH> <B_SWITCH> [--elab]: pairjudge.py for a single-file case (golden by case.py)."""
import sys, subprocess, os, json
H=os.path.dirname(os.path.abspath(__file__))
c,A,B=sys.argv[1:4]; el=['--elab'] if '--elab' in sys.argv else []
r=json.loads(subprocess.run(['python3',f'{H}/case.py']+el+[c,'ON=',f'A={A}',f'B={B}',f'AB={A},{B}'],capture_output=True,text=True).stdout)
W=f'/tmp/r11u143_cases/{r["key"]}'
S={};V={};DV={}
for n in ('ON','A','B','AB'):
    V[n]=r[n].get('strict','nodb')
    S[n]={tuple(map(int,l.split())) for l in open(f'{W}/{n}.diffs')} if os.path.exists(f'{W}/{n}.diffs') else set()
    if not os.path.exists(f'{W}/{n}.rec'): DV[n]=0; continue
    G=[l.split('\t')[:4] for l in open(f'{W}/g_{n}.rec').read().split('\n')[:-1]]; X=[l.split('\t')[:4] for l in open(f'{W}/{n}.rec').read().split('\n')[:-1]]
    DV[n]=next((i for i in range(min(len(G),len(X))) if G[i]!=X[i]),min(len(G),len(X)))
lim=min(DV.values()); f=lambda n:{x for x in S[n] if x[0]<lim}
canc=(f('A')&f('B'))-f('AB')
eqc=V['AB'].startswith('STRICT_EQUAL') and not (V['A'].startswith('STRICT_EQUAL') and V['B'].startswith('STRICT_EQUAL'))
print(f"{'/'.join(c.split('/')[-3:])} {A}+{B}: ON[{V['ON']}] Aoff[{V['A']}] Boff[{V['B']}] both[{V['AB']}] aligned<{lim} | A={len(f('A'))} B={len(f('B'))} AB={len(f('AB'))} (AnB)-AB={len(canc)} -> {'CANCELLATION' if canc or eqc else 'no cancellation'}")
