#!/usr/bin/env python3
"""lawtable.py -> markdown tables per law (default mode, elab mode, downstream) for README"""
import json, subprocess, re, os, collections, sys
sys.path.insert(0,'/tmp/r11u141_drv'); from lawmap import *
BYNAME={v[0]:v[1] for v in LAWS.values()}
def load(p):
    d={}
    for l in open(p):
        r=json.loads(l); d[r['case'].rstrip('/')]=r
    return d
D=load('/tmp/r11u141_run_full.jsonl')
for x in ('ena','more','res'): D.update(load(f'/tmp/r11u141_run_{x}.jsonl'))
E=load('/tmp/r11u141_run_elab.jsonl')
for x in ('ena_elab','more_elab','res_elab'): E.update(load(f'/tmp/r11u141_run_{x}.jsonl'))
F=load('/tmp/r11u141_fix_def.jsonl'); F.update(load('/tmp/r11u141_fix_more.jsonl')); FE=load('/tmp/r11u141_fix_elab.jsonl')
DS=collections.defaultdict(dict)
for l in open('/tmp/r11u141_ds_cases.jsonl'):
    r=json.loads(l); DS[r['case'].rstrip('/')][r['tag']]=r['verdict']
def j(key,P,L,two=False):
    return subprocess.run(['python3','/tmp/r11u141_drv/judge2.py' if two else '/tmp/r11u141_drv/judge.py',f'/tmp/r11u141_cases/{key}',P,L],capture_output=True,text=True).stdout.strip()
def st(x):
    if not x or x.get('md5') is None: return 'no db'
    s=x.get('strict','')
    if s.startswith('STRICT_EQUAL'): return 'equal'
    if 'stage1' in s: return f"stage1 cmp={x.get('cmp')}"
    f=x.get('fields','').replace('fields: ','').replace(' objects_differing=',' obj=')
    return 'ne:'+s.split()[-1]+f'({f.split(" obj=")[-1].split()[0] if "obj=" in f else "?"})'
DDK={}
def ddnote(key,P,L):
    r=subprocess.run(['python3','/tmp/r11u141_drv/dd.py',f'/tmp/r11u141_cases/{key}',P,L],capture_output=True,text=True).stdout.strip()
    m=re.search(r'newbad=(\d+) fixed=(\d+)',r)
    return f' (dump lines: {m.group(2)} fixed, {m.group(1)} new)' if m else ''
def short(v):
    v=v.split(' P=')[0]
    return {'SAME':'untouched','TURNED':'**turned equal**','STAGE1-both':'stage1 both'}.get(v,v)
rows=collections.defaultdict(list)
for c,r in sorted(D.items()):
    if '/cases/' not in c: continue
    law='§ '+re.search(r'§ (\S+)',open(c+'/dut.sv').readline()).group(1)
    sw=BYNAME[law]; grp=c.split('/cases/')[1]
    if not r.get('golden'): rows[law].append(f'| {grp} | no golden | | | | |'); continue
    k=r['key']; e=E.get(c,{})
    dv=j(k,sw,'ON') if sw in r else 'n/a'
    if dv.startswith('STAGE1-both'): dv='stage1 both, bytes moved'+ddnote(k,sw,'ON')
    ev=j(e['key'],sw,'ON') if e.get(sw) else ('SAME' if e.get('R11U130_OFF') is None and e.get('ON',{}).get('md5')==e.get('A3',{}).get('md5') else 'n/a')
    if sw not in e:
        # elab runs carried ON/A3/P*/own: own is present by runall
        pass
    a3=j(k,'A3','ON')
    if a3.startswith('STAGE1-both'): a3='stage1 both, bytes moved'+ddnote(k,'A3','ON')
    ds=DS.get(c,{}); dss=ds.get('ON','?')+('' if len(set(ds.values()))<=1 else ' (law off: '+ds.get('OWN','?')+', A3: '+ds.get('A3','?')+')')
    fx=''
    if c in F and F[c].get('F',{}).get('md5')!=r['ON'].get('md5'):
        fx=' fix: '+short(j(F[c]['key'],'ON','F'))
    rows[law].append(f"| {grp} | {st(r['ON'])} | {st(r.get(sw))} → {st(r['ON'])}: {short(dv)} | {short(ev)} | {short(a3)} | {dss} |{fx}")
for law in [v[0] for v in LAWS.values()]:
    if law not in rows: continue
    print(f'\n#### {law} (`{BYNAME[law]}`)\n')
    print('| case | at e98516a3 | law off → on (default) | law off → on (`--elabuhdm`) | three passes off → on | downstream (law on) |')
    print('|---|---|---|---|---|---|')
    for x in rows[law]: print(x)
