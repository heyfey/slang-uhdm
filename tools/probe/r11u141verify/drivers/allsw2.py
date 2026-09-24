#!/usr/bin/env python3
import sys, json, subprocess
for line in open(sys.argv[1]):
    r=json.loads(line); name='/'.join(r['case'].rstrip('/').split('/')[-2:])
    if not r.get('golden'): continue
    on=r['ON']['md5']
    for c,x in r.items():
        if not isinstance(x,dict) or c=='ON' or x.get('md5')==on or x.get('md5') is None: continue
        v=subprocess.run(['python3','/tmp/r11u141_drv/judge2.py',f'/tmp/r11u141_cases/{r["key"]}',c,'ON'],capture_output=True,text=True).stdout.strip()
        if not v.startswith(('OK2','NA2')): print(name,c,v)
print('done')
