#!/usr/bin/env python3
"""runall.py <out.jsonl> [--elab] [--full] casedirs... : run case.py per case with ON, A3, P130/P131/P134, the case's own
law switch (from the first line's §), [--full: every single switch]; parallel 3."""
import sys, os, subprocess, json, re
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0,'/tmp/r11u141_drv'); from lawmap import *
out=sys.argv[1]; args=sys.argv[2:]; elab='--elab' in args; full='--full' in args
cases=[a for a in args if not a.startswith('--')]
BYNAME={v[0]:v[1] for v in LAWS.values()}
def cfgs(c):
    first=open(os.path.join(c,'dut.sv')).readline()
    m=re.search(r'§ (\S+)',first); law='§ '+m.group(1) if m else None
    cs=['ON=','A3='+A3]+[f'P{p}={s}' for p,s in PASSOFF.items()]
    own=BYNAME.get(law)
    sws=ALLSW if full else ([own] if own else [])
    if own=='R11V131_ARGCTX_OFF' and not full: sws=[own,'R11U131_IPSSPAN_OFF','R11U131_QCALL_OFF']
    cs+=[f'{s}={s}' for s in sws]
    return cs
def one(c):
    r=subprocess.run(['python3','/tmp/r11u141_drv/case.py']+(['--elab'] if elab else [])+[c]+cfgs(c),capture_output=True,text=True)
    return r.stdout.strip() or json.dumps({'case':c,'error':r.stderr[-400:]})
with ThreadPoolExecutor(3) as ex, open(out,'w') as f:
    for line in ex.map(one,cases): f.write(line+'\n'); f.flush()
