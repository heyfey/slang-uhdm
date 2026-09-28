#!/usr/bin/env python3
"""fixjudge.py <fixbound.txt>: every case-mode fixbound.sh reads MOVED is judged law.bin vs fix.bin against its golden
(case.sh with tags `law` and `fix`, GW=/tmp/r11u199_g): uhdm-cmp lines, the strict verdict, and the ORDER-BLIND uhdm-dump
judge (reachable part, basenames): lost = golden-agreeing lines law had that fix lost (AWAY), gained = golden-agreeing
lines fix has that law lacked, dist = multiset distance to golden per binary.  Fail-closed on $FENCED."""
import os, re, sys, subprocess, collections
FEN = os.environ.get('FENCED', '').split()
if len(FEN) != 4: sys.exit('fixjudge.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__)); R = os.environ['R199_ROOT']; DUMP = os.environ['UHDM_DUMP']
def lines(u):
    L = subprocess.run([DUMP, u], capture_output=True, text=True, errors='replace').stdout.splitlines()
    L = L[:next((i for i, l in enumerate(L) if l.startswith('\\_weaklyReferenced')), len(L))]
    return collections.Counter(re.sub(r'/[^ ,:()]*/', '', l).rstrip() for l in L if 'Restored design' not in l)
for l in open(sys.argv[1]):
    f = l.split()
    if 'MOVED' not in f: continue
    rel = f[0]; el = 'el' in f[1:2]
    c = f'{R}/tools/probe/{rel}'
    if any(re.search(rf'\b{re.escape(n)}\b', c) for n in FEN): continue
    env = dict(os.environ, EL='1' if el else '0')
    out = {}
    for tag, b in (('law', os.environ['LAW']), ('fix', os.environ['FIX'])):
        out[tag] = subprocess.run([f'{D}/case.sh', c, tag, b], capture_output=True, text=True, env=env).stdout.strip()
    w = '/tmp/r11u199_g/' + rel.split('/cases/')[1] + ('_el' if el else '')
    g = [os.path.join(w, x, 'golden.uhdm') for x in os.listdir(w) if x.startswith('gold_')][0]
    G, A, B = lines(g), lines(f'{w}/law.uhdm'), lines(f'{w}/fix.uhdm')
    lost = sum((((A & G) - B)).values()); gained = sum((((B & G) - A)).values())
    da = sum(((A - G) + (G - A)).values()); db = sum(((B - G) + (G - B)).values())
    s = lambda t: re.search(r'cmplines=(\d+) strict=(\S+)', out[t]).groups()
    print(f"{rel}{' el' if el else ''} | law cmp={s('law')[0]} {s('law')[1]} dist={da} | fix cmp={s('fix')[0]} {s('fix')[1]} dist={db} | lost={lost} gained={gained}")
