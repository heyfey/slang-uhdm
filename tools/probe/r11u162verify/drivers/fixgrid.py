#!/usr/bin/env python3
"""fixgrid.py [--el] <fixbin> <casedir>...: the fix binary against the law binary's ON database (from grid.py's
scratch) on each case: SAME-AS-ON, or the fix's strict verdict and its record delta against ON
(TOWARD / AWAY / MIXED / STAGE1-x by order-blind dump distance).  Fail-closed on $FENCED."""
import os, re, sys, subprocess, glob, collections, hashlib
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('fixgrid.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(D, 'grid.py')).read(); ns = {'__name__': 'x', '__file__': os.path.join(D, 'grid.py')}
exec(src[:src.index('def main')], ns)
args = sys.argv[1:]; el = False
if args[0] == '--el': el = True; args = args[1:]
fb = args[0]
for case in args[1:]:
    case = os.path.abspath(case)
    if any(re.search(rf'\b{re.escape(n)}\b', case) for n in FENCED): print('FENCED-SKIP', case); continue
    w = ns['wdir'](case, el); rel = w.split(ns['GW'] + '/')[1]
    env = dict(os.environ); env['EL'] = '1' if el else '0'
    line = subprocess.run([f'{D}/case.sh', case, 'fix', fb], capture_output=True, text=True, env=env).stdout.strip()
    g = glob.glob(f'{w}/gold_*/golden.uhdm')
    if not g or not os.path.exists(f'{w}/fix.uhdm'): print(rel, 'NOGOLD-OR-NODB', line); continue
    if ns['md5'](f'{w}/fix.uhdm') == ns['md5'](f'{w}/on.uhdm'): print(rel, 'SAME-AS-ON'); continue
    v, det = ns['score'](w, 'fix', 'on', g[0])
    print(rel, 'MOVED', line.split('strict=')[1].split()[0], v, det, flush=True)
