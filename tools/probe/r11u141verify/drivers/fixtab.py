import json, subprocess, sys, os, hashlib
def md5(p): return hashlib.md5(open(p,'rb').read()).hexdigest() if os.path.exists(p) else None
tot=0; offpris=0; moved=[]
for line in open(sys.argv[1]):
    r=json.loads(line); k=r['key']; wd=f'/tmp/r11u141_cases/{k}'; n='/'.join(r['case'].rstrip('/').split('/')[-2:])
    tot+=1
    on,f,foff,fq,ft=(md5(f'{wd}/{x}.uhdm') for x in ('ON','F','FOFF','FQ','FT'))
    if foff==on: offpris+=1
    else: print('OFF!=PRISTINE',n)
    if f!=on:
        v=subprocess.run(['python3','/tmp/r11u141_drv/judge.py',wd,'ON','F'],capture_output=True,text=True).stdout.strip()
        own=[s for s,x in (('IPSQUAL',fq),('INCTABACT',ft)) if x!=f]
        back=[s for s,x in (('IPSQUAL',fq),('INCTABACT',ft)) if x==on]
        moved.append(n); print('MOVED',n,v.split(' ')[0],'switches that move it back:',back, '| pristine->fix', v[:140])
print(f'cases {tot}; R11V141_OFF == pristine bytes on {offpris}; fix moves {len(moved)}')
