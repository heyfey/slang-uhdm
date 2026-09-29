#!/usr/bin/env python3
"""r11u229: flatinspect.py <case-view store> <off tag>: every flat-key record a state (<off tag>) held that `on` lost,
with its ancestor chains and the counts off / on / golden at each (records from drivers/caseaway.py's cache, so run
caseaway.py first).  A record whose every changed chain has golden < off is a removed extra (a flat-key collision),
not a lost golden record.  Prints VERDICT removed-extra / LOST per record."""
import os, sys, glob, pickle, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('flatinspect.py: source drivers/env.sh first')
CD = os.environ.get('AWAYCACHE', '/tmp/r11u229_awaycache')
def md5(p): return hashlib.md5(open(p, 'rb').read()).hexdigest()
def keyed(u): return pickle.load(open(f'{CD}/{md5(u)}.k', 'rb'))
d, t = sys.argv[1:3]
G, Gf = keyed(glob.glob(d + '/gold_*/golden.uhdm')[0]); N, Nf = keyed(d + '/on.uhdm'); O, Of = keyed(f'{d}/{t}.uhdm')
for r, v in ((Of & Gf) - Nf).items():
    ctx = [(k[0], O[k], N[k], G.get(k, 0)) for k in set(O) | set(N) if k[1] == r and O[k] != N[k]]
    extra = all(b < a and g < a for c, a, b, g in ctx)
    print(f'{d.split("/r11u229_g/")[-1]} {t} FLAT_LOST {v} {r[:120]} VERDICT {"removed-extra" if extra else "LOST"}')
    for c, a, b, g in ctx: print(f'   off={a} on={b} golden={g} @ {c[:200]}')
