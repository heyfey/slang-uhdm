#!/usr/bin/env python3
# Waits until no sweep/runner process is live: two consecutive quiet readings 20 s apart.
# Excludes this process, its ancestors, the session wrapper shells (shell-snapshots, 'sh -s --').
import os, re, time, sys
PAT = re.compile(r'sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests')
def ancestors():
    s = set(); p = os.getpid()
    while p > 1:
        s.add(p)
        try:
            with open(f'/proc/{p}/stat') as f: p = int(f.read().rsplit(')',1)[1].split()[1])
        except Exception: break
    return s
def live():
    anc = ancestors(); out = []
    for d in os.listdir('/proc'):
        if not d.isdigit() or int(d) in anc: continue
        try:
            with open(f'/proc/{d}/cmdline','rb') as f: cl = f.read().replace(b'\0',b' ').decode(errors='replace').strip()
        except Exception: continue
        if not cl or 'shell-snapshots' in cl or cl.startswith('sh -s --') or 'v11u468_quietwait' in cl: continue
        if PAT.search(cl): out.append(f'{d} {cl[:160]}')
    return out
q = 0
verbose = '-v' in sys.argv
while q < 2:
    l = live()
    if l:
        q = 0
        if verbose: print('\n'.join(l), flush=True)
    else: q += 1
    if q < 2: time.sleep(20)
print('quiet', flush=True)
