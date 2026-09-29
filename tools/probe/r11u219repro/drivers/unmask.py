#!/usr/bin/env python3
"""unmask.py <pristine sweep wd> <law sweep wd> <case>...: for each probe case whose strict detail changed, the law
database's first differing record (index and field) and whether the pristine database already differed at that
index (uhdm-strictcmp --max 100000 against the case's cached golden): an unmasking reads `pristine at same index`."""
import os, re, sys, subprocess
SC = os.environ['STRICT_CMP']
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp
P, L = sys.argv[1:3]
def recs(g, o):
    r = subprocess.run([SC, '--max', '100000', g, o], capture_output=True, text=True).stdout.splitlines()
    idx = {}; last = r[-2] if len(r) > 1 else ''
    for l in r:
        m = re.match(r'#(\d+) (\S+)', l)
        if m: idx.setdefault(int(m.group(1)), m.group(2))
    return idx, last
for c in sys.argv[3:]:
    g = os.path.join(cp.cache_dir(c), 'golden.uhdm'); b = c.replace('/', '__') + '.uhdm'
    pi, pl = recs(g, f'{P}/probe/{b}'); li, ll = recs(g, f'{L}/probe/{b}')
    if not li: print(c, '| law: equal'); continue
    k = min(li); print(f'{c} | law first: #{k} {li[k]} | pristine at same index: ' + (f'#{k} {pi[k]}' if k in pi else 'NONE') + f' | pristine {pl}')
