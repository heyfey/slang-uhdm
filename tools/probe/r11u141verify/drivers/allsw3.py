#!/usr/bin/env python3
# stage-1 movers: order-blind dump delta, every config vs ON
import sys, json, subprocess
for line in open(sys.argv[1]):
    r=json.loads(line); name='/'.join(r['case'].rstrip('/').split('/')[-2:])
    if not r.get('golden') or r['ON'].get('md5') is None or 'stage1' not in r['ON'].get('strict',''): continue
    on=r['ON']['md5']
    for c,x in r.items():
        if not isinstance(x,dict) or c=='ON' or x.get('md5') in (on,None): continue
        v=subprocess.run(['python3','/tmp/r11u141_drv/dd.py',f'/tmp/r11u141_cases/{r["key"]}',c,'ON'],capture_output=True,text=True).stdout.strip()
        print(name,c,r['ON'].get('cmp'),x.get('cmp'),v)
