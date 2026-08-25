#!/usr/bin/env python3
"""r10uvm147 — the AWAY-GOLDEN detector.  For ONE arm and ONE view, classify
every census cell by its PRISTINE and PATCHED verdict against golden:
  TO-GOLDEN    wrong pristine -> right patched
  AWAY-GOLDEN  right pristine -> wrong patched   <- must be 0
  STILL-WRONG  wrong both
  UNMOVED-OK   right both
  usage: away147.py <golden.cen> <pris.cen> <pat.cen>
"""
import sys, collections
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        f = ln.split('\t'); k = f[0]; i = k.find(':'); k = k[i+1:]
        d[k].append(dict(x.partition('=')[::2] for x in f[1:]))
    return d
def verdicts(g, o):
    v = {}
    for k in set(g) | set(o):
        gl, ol = g.get(k, []), o.get(k, [])
        for i in range(max(len(gl), len(ol))):
            gp = gl[i] if i < len(gl) else None
            op = ol[i] if i < len(ol) else None
            if gp is None or op is None:
                v[(k, i)] = 'ONLY'
            else:
                v[(k, i)] = 'OK' if all(gp.get(f) == op.get(f) for f in
                    ('SIG','NELEM','NSTEP','TRAILSEL')) else 'BAD'
    return v
g = load(sys.argv[1]); a = verdicts(g, load(sys.argv[2])); b = verdicts(g, load(sys.argv[3]))
c = collections.Counter(); away = []
for k in set(a) | set(b):
    x, y = a.get(k, 'ONLY'), b.get(k, 'ONLY')
    if x == 'OK' and y == 'OK': c['UNMOVED-OK'] += 1
    elif x != 'OK' and y == 'OK': c['TO-GOLDEN'] += 1
    elif x == 'OK' and y != 'OK': c['AWAY-GOLDEN'] += 1; away.append((k, y))
    else: c['STILL-WRONG'] += 1
for k, y in sorted(away)[:20]: print("AWAY", k, y)
print(" ".join(f"{k}={c[k]}" for k in
      ('TO-GOLDEN','AWAY-GOLDEN','STILL-WRONG','UNMOVED-OK')))
