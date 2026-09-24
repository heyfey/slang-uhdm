#!/usr/bin/env python3
"""pairjudge.py <corpus> <mode> <test> <A_SWITCH> <B_SWITCH>: the row with law A off, law B off, both off, and on;
strict diff sets (golden walk index, field) up to the earliest walk divergence of the four. CANCELLATION when a field
differs with A off and with B off but matches golden with both off (each law's error hidden by the other), or when the
row is strict-equal with both off and not with one off."""
import sys, subprocess, os
H=os.path.dirname(os.path.abspath(__file__))
c,m,t,A,B=sys.argv[1:6]
subprocess.run(['python3',f'{H}/rowsw.py',c,m,t,'ON=',f'A={A}',f'B={B}',f'AB={A},{B}'],capture_output=True)
W=f'/tmp/r11u143_rowsw/{t}_{m}'
import glob,re
g=re.search(r'golden cache hit ([^)]*)\)',open(glob.glob(f'/tmp/r11u143_wdON/{c}/{m}/{t}-*/cmds.txt')[0]).read()).group(1)+'/golden.uhdm'
S={}; V={}; DV={}
for n in ('ON','A','B','AB'):
    r=subprocess.run(['/tmp/r11u143_bin/strictx','--max','0','--diffs',f'{W}/{n}.d','--dump-a',f'{W}/g{n}.rec','--dump-b',f'{W}/{n}.rec',g,f'{W}/{n}.uhdm'],capture_output=True,text=True)
    V[n]=(r.stdout+r.stderr).strip().splitlines()[-1]
    S[n]={tuple(map(int,l.split())) for l in open(f'{W}/{n}.d')} if os.path.exists(f'{W}/{n}.d') else set()
    G=[l.split('\t')[:4] for l in open(f'{W}/g{n}.rec').read().split('\n')[:-1]]; X=[l.split('\t')[:4] for l in open(f'{W}/{n}.rec').read().split('\n')[:-1]]
    DV[n]=next((i for i in range(min(len(G),len(X))) if G[i]!=X[i]),min(len(G),len(X)))
lim=min(DV.values())
f=lambda n:{x for x in S[n] if x[0]<lim}
canc=(f('A')&f('B'))-f('AB')
eqcanc=V['AB'].startswith('STRICT_EQUAL') and not (V['A'].startswith('STRICT_EQUAL') and V['B'].startswith('STRICT_EQUAL'))
print(f"{c}/{m}/{t} {A}+{B}: ON[{V['ON']}] Aoff[{V['A']}] Boff[{V['B']}] both[{V['AB']}] aligned<{lim} | fields A={len(f('A'))} B={len(f('B'))} AB={len(f('AB'))} AB-(AuB)={len(f('AB')-(f('A')|f('B')))} (AnB)-AB={len(canc)} -> {'CANCELLATION' if canc or eqcanc else 'conjunction/independent (no cancellation)'}")
