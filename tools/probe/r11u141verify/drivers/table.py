#!/usr/bin/env python3
"""table.py <run.jsonl> : per case: ON verdict, own-law judge (switch off -> on), pass-off judge, A3 judge"""
import sys, json, subprocess, os, re
sys.path.insert(0,'/tmp/r11u141_drv'); from lawmap import *
BYNAME={v[0]:v[1] for v in LAWS.values()}
def j(key,P,L):
    return subprocess.run(['python3','/tmp/r11u141_drv/judge.py',f'/tmp/r11u141_cases/{key}',P,L],capture_output=True,text=True).stdout.strip()
def st(x):
    if not x or x.get('md5') is None: return f"rc={x.get('rc') if x else '?'} NODB"
    s=x.get('strict','')
    return ('cmp=%s '%x.get('cmp'))+(s.split()[0]+(':'+s.split()[1] if len(s.split())>1 and not s.startswith('STRICT_EQUAL') else '') if s else '?')
for line in open(sys.argv[1]):
    r=json.loads(line); c=r['case']; name='/'.join(c.split('/')[-2:])
    if not r.get('golden'): print(f'{name}\tNOGOLDEN\t{st(r.get("ON"))}'); continue
    law=re.search(r'§ (\S+)',open(c+'/dut.sv').readline()); law='§ '+law.group(1)
    sw=BYNAME.get(law); p=sw[4:7] if sw else None
    own=j(r['key'],sw,'ON') if sw in r else '-'
    po=j(r['key'],f'P{p}','ON')
    a3=j(r['key'],'A3','ON')
    print(f"{name}\t{law}\tON[{st(r['ON'])}]\tOFF[{st(r.get(sw))}]\town:{own.split(' ')[0]}\tpass:{po.split(' ')[0]}\tA3:{a3.split(' ')[0]}\t|{own}")
