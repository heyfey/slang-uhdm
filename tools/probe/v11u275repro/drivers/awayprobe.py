#!/usr/bin/env python3
# v11u275 awayprobe.py <pristine probe dir> <law probe dir> <mover list>: the order-blind (away.py) and chain-keyed
# (awaychain.py) away census of each probe mover (names as check_probe writes them, dir__case.uhdm) against its
# cached golden. Fail-closed on $FENCED.
import os, re, sys, subprocess
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awayprobe.py: FENCED unset')
D = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.abspath(os.path.join(D, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp, verify_golden as vg
P, L, M = sys.argv[1:4]
for b in open(M).read().split():
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', b) for f in F):
        print(b, 'FENCED-REFUSED'); continue
    rel = b[:-5].replace('__', '/')
    hit = vg.cache_load(cp.cache_dir(rel))
    g = hit[1] if hit else None
    if not g: print(rel, 'NO-GOLDEN'); continue
    t = os.path.join(os.environ['S'], 'awayprobe', b); os.makedirs(t, exist_ok=True)
    a = subprocess.run(['python3', f'{D}/away.py', g, f'{P}/{b}', f'{L}/{b}', t], capture_output=True, text=True).stdout.splitlines()
    c = subprocess.run(['python3', f'{D}/awaychain.py', g, f'{P}/{b}', f'{L}/{b}'], capture_output=True, text=True).stdout.splitlines()
    print(rel, (a[0] if a else '?'), '|', (c[0] if c else '?'))
