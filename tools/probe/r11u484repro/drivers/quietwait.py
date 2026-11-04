#!/usr/bin/env python3
# quietwait.py [max_seconds]: waits until no sweep, runner or corpus stage process is live on the
# machine (its own pid and ancestors excluded, by /proc), polling every 30 s; exits 0 when quiet,
# 1 on timeout.  Prints the live processes it waits on once per 10 minutes.
import os, re, sys, time
PAT = re.compile(r'sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests')
def mine():
    s, p = set(), os.getpid()
    while p > 1:
        s.add(p)
        try: p = int(open(f'/proc/{p}/stat').read().split(')')[1].split()[1])
        except Exception: break
    return s
def live():
    me, out = mine(), []
    for d in os.listdir('/proc'):
        if not d.isdigit() or int(d) in me: continue
        try: cmd = open(f'/proc/{d}/cmdline','rb').read().replace(b'\0', b' ').decode(errors='replace')
        except Exception: continue
        if PAT.search(cmd) and 'quietwait' not in cmd: out.append(f'{d} {cmd[:160]}')
    return out
t0, last = time.time(), 0
mx = float(sys.argv[1]) if len(sys.argv) > 1 else 7200
while True:
    l = live()
    if not l: sys.exit(0)
    if time.time() - last > 600:
        print(time.strftime('%H:%M:%S'), 'waiting on', len(l), l[0], flush=True); last = time.time()
    if time.time() - t0 > mx: sys.exit(1)
    time.sleep(30)
