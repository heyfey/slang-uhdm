#!/usr/bin/env python3
"""sizevals.py <case-view scratch dir>...: for every cont_assign in golden, pristine (P.uhdm) and law (L.uhdm) (each
database walked alone by uhdm-strictcmp, its record dump), its left side's name and its right side's record (type,
decompile, value): the $size fold values side by side."""
import sys, glob, os, subprocess
def ca(u):
    f = '/tmp/v11u219_sizevals.rec'
    subprocess.run([os.environ['STRICT_CMP'], '--max', '0', '--dump-a', f, '--dump-b', '/dev/null', u, u], capture_output=True)
    out = {}; recs = [l.rstrip('\n').split('\t') for l in open(f, errors='replace') if l[:1].isdigit()]
    for i, r in enumerate(recs):
        if r[1] != 'cont_assign': continue
        d = int(r[0]); kids = []
        for s in recs[i + 1:]:
            if int(s[0]) <= d: break
            if int(s[0]) == d + 1: kids.append(s)
        if len(kids) >= 2:
            lhs = kids[1][2] or kids[1][4]; rhs = kids[0]
            out.setdefault(lhs, set()).add(f'{rhs[1]}:{rhs[10]}:{rhs[12]}')
    return out
for d in sys.argv[1:]:
    gg = glob.glob(d + '/gold_*/golden.uhdm')
    if not gg or not os.path.exists(d + '/L.uhdm') or not os.path.exists(d + '/P.uhdm'): print('==', d.split('/g/')[-1], 'no databases'); continue
    g = ca(gg[0]); p = ca(d + '/P.uhdm'); l = ca(d + '/L.uhdm')
    print('==', d.split('/g/')[-1])
    for k in sorted(set(g) | set(p) | set(l)):
        if not k.startswith(('w', 'nw', 'iw', 'gw')): continue
        G, P, L = sorted(g.get(k, [])), sorted(p.get(k, [])), sorted(l.get(k, []))
        flag = '' if G == L else ('  <-- L!=G' + (' (P==G: BREAK)' if P == G else ''))
        print(f'  {k:4} G={G} P={P} L={L}{flag}')
