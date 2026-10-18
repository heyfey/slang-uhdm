#!/usr/bin/env python3
# away.py golden.uhdm pristine.uhdm law.uhdm : order-blind multiset census over normalized uhdm-dump lines
import subprocess, sys, re, collections, os
D = os.environ['UHDM_DUMP']
def lines(p):
    out = subprocess.run([D, p], capture_output=True, text=True, errors='replace').stdout
    res = collections.Counter()
    for l in out.splitlines():
        l = re.sub(r'id:\d+', 'id:', l)
        l = re.sub(r'/[^ ,]*/', '', l)   # strip directories
        l = l.strip()
        if l.startswith('===') or not l or 'Restored design' in l: continue
        res[l] += 1
    return res
g, p, l = (lines(x) for x in sys.argv[1:4])
toward = away = 0
aw = []
for k in set(g) | set(p) | set(l):
    dp, dl = abs(p[k] - g[k]), abs(l[k] - g[k])
    if dl < dp: toward += dp - dl
    elif dl > dp: away += dl - dp; aw.append(k)
print(f'toward={toward} away={away} pdiff={sum(abs(p[k]-g[k]) for k in set(g)|set(p))} ldiff={sum(abs(l[k]-g[k]) for k in set(g)|set(l))}')
for k in aw[:int(os.environ.get('SHOW', '8'))]: print('  AWAY', k[:160])
