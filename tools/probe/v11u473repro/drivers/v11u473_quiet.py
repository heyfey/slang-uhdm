#!/usr/bin/env python3
# Waits until no sweep/runner process is live for two readings 30 s apart (max N seconds); excludes own ancestors and session shells.
import os, re, time, sys
PAT = re.compile(r'sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests')
def anc():
    s=set(); p=os.getpid()
    while p>1:
        s.add(p)
        try: p=int(open(f'/proc/{p}/stat').read().rsplit(')',1)[1].split()[1])
        except Exception: break
    return s
def live():
    a=anc(); out=[]
    for d in os.listdir('/proc'):
        if not d.isdigit() or int(d) in a: continue
        try: cl=open(f'/proc/{d}/cmdline','rb').read().replace(b'\0',b' ').decode(errors='replace').strip()
        except Exception: continue
        if not cl or 'shell-snapshots' in cl or cl.startswith('sh -s --') or 'v11u473_quiet' in cl or '_wait' in cl: continue
        if PAT.search(cl): out.append(d+' '+cl[:120])
    return out
lim=float(sys.argv[1]) if len(sys.argv)>1 else 580; t0=time.time(); q=0
while q<3 and time.time()-t0<lim:
    l=live(); q=0 if l else q+1
    if q<3: time.sleep(60)
print('quiet' if q>=3 else 'busy:\n'+'\n'.join(live()))
