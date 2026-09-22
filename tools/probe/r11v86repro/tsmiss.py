#!/usr/bin/env python3
"""VERIFIER — count the module-route MINT's signed typespec that golden writes
(`CompileExpression.cpp:3032-3040`, `if (sval->isSigned())`) and we do not.
Prints, per arm, cells where golden carries a typespec and BOTH our binaries
carry none, and the converse."""
import os, re, subprocess, sys
PROBE='/tmp/v11u86_g/ts81probe'
def probe(db):
    out=subprocess.run([PROBE,db],capture_output=True,text=True).stdout
    secs,cur=[],None
    for l in out.splitlines():
        m=re.match(r'TOP(\w+) (\S+) op(\d+) n=(\d+)',l)
        if m: cur=[(m.group(1),m.group(2),m.group(3),m.group(4)),[]]; secs.append(cur); continue
        m=re.match(r'\s+\[(\d+)\] (.*)',l)
        if m and cur is not None: cur[1].append(m.group(2).strip())
    return secs
def ts(cell):
    m=re.search(r'ts=(.*)$',cell); return m.group(1) if m else None
grid=sys.argv[1]
miss=extra=0
for arm in sorted(a[2:] for a in os.listdir(grid) if a.startswith('g_')):
    gdir=f'{grid}/g_{arm}/slpp_all'
    if not os.path.isdir(gdir): continue
    gd=[f'{gdir}/{x}' for x in os.listdir(gdir) if x.endswith('.uhdm')]
    pb=f'{grid}/o_{arm}_lawx/ours.uhdm'
    if not gd or not os.path.exists(pb): continue
    G,B=probe(gd[0]),probe(pb)
    if len(G)!=len(B): continue
    m=e=0
    for gs,bs in zip(G,B):
        for gc,bc in zip(gs[1],bs[1]):
            gt,bt=ts(gc),ts(bc)
            if gt is None or bt is None: continue
            if gt!='-' and bt=='-': m+=1
            elif gt=='-' and bt!='-': e+=1
    if m or e: print(f'{arm:<18} golden-has-ours-lacks={m}  ours-has-golden-lacks={e}')
    miss+=m; extra+=e
print(f'TOTAL golden-has-ours-lacks={miss}  ours-has-golden-lacks={extra}')
