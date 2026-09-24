#!/usr/bin/env python3
"""allsw.py <run.jsonl> : for every case and every config C != ON, judge C (law off) -> ON (law on); print non-SAME,
flag BREAK/WORSE/GROW."""
import sys, json, subprocess
def j(key,P,L):
    return subprocess.run(['python3','/tmp/r11u141_drv/judge.py',f'/tmp/r11u141_cases/{key}',P,L],capture_output=True,text=True).stdout.strip()
flags=[]
for line in open(sys.argv[1]):
    r=json.loads(line); name='/'.join(r['case'].rstrip('/').split('/')[-2:])
    if not r.get('golden'): print(name,'NOGOLDEN'); continue
    on=r['ON']['md5']
    movers=[]
    for c,x in r.items():
        if not isinstance(x,dict) or c=='ON': continue
        if x.get('md5')==on: continue
        v=j(r['key'],c,'ON'); movers.append(f'{c}:{v.split()[0]}')
        if v.startswith(('BREAK','WORSE','GROW')): flags.append(f'{name} {c} {v}')
    print(name, r['ON'].get('strict','?').split()[0], ' '.join(movers))
print('== FLAGS'); print('\n'.join(flags) or 'none')
