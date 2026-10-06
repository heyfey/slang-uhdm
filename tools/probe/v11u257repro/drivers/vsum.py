#!/usr/bin/env python3
# (v11u257) reads only a vgrid.sh output file (case.sh lines); opens no database.
# v11u257 vsum.py <vgrid.txt>: per case-view the verdict on every configuration; counts of moves, entries and exits
# of STRICT_EQUAL (fix against pristine and against law), the R11V257_OFF = law bytes and R11U257_OFF = pristine bytes checks.
import sys, collections
R = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    cfg, cv = f[0], f[1]
    d = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    st = d.get('strict', f[2] if 'FAIL' in f[2] else '?')
    R[cv][cfg] = (st, d.get('md5', '-'), d.get('rc', '?'), d.get('cmplines', '-'))
n = len(R); c = collections.Counter(); bad = []
for cv, r in sorted(R.items()):
    P, L, F = r.get('vP'), r.get('vL'), r.get('vF')
    if not (P and L and F): bad.append(cv + ' incomplete'); continue
    eq = lambda s: s[0].startswith('STRICT_EQUAL')
    c['rc!=0'] += sum(1 for k in r.values() if k[2] != '0')
    if F[1] != P[1]: c['fix moves vs pristine'] += 1
    if F[1] != L[1]: c['fix moves vs law'] += 1; print('FIXvsLAW', cv, 'L=' + L[0], 'F=' + F[0], 'cmplines', L[3], '->', F[3])
    if eq(F) and not eq(P): c['fix enters STRICT_EQUAL vs pristine'] += 1
    if eq(P) and not eq(F): c['fix LEAVES STRICT_EQUAL vs pristine'] += 1; print('LEAVE-P', cv, P[0], '->', F[0])
    if eq(L) and not eq(F): c['fix LEAVES vs law'] += 1; print('LEAVE-L', cv)
    if eq(F) and not eq(L): c['fix enters vs law'] += 1
    if eq(P) and not eq(L): c['law LEAVES vs pristine'] += 1; print('LAW-LEAVE', cv, P[0], '->', L[0])
    if P[0].startswith('STRICT') and not L[0].startswith('STRICT'): print('LAW-JUDGE-LOSS', cv, P[0], '->', L[0])
    if P[0].startswith('STRICT') and not F[0].startswith('STRICT'): print('FIX-JUDGE-LOSS', cv, P[0], '->', F[0])
    if r.get('vFV', ('', ''))[1] == L[1]: c['R11V257_OFF = law bytes'] += 1
    else: print('FV!=L', cv)
    if r.get('vFU', ('', ''))[1] == P[1]: c['R11U257_OFF = pristine bytes'] += 1
    else: c['R11U257_OFF != pristine (single draw)'] += 1; print('FU!=P', cv)
print(f'case-views={n}', dict(c), bad)
# per-switch: case-views a refinement's switch moves against the fix, and whether it gives the law's bytes there
for sw in ('vFA', 'vFH', 'vFC'):
    m = [cv for cv, r in R.items() if sw in r and r[sw][1] != r['vF'][1]]
    print(sw, 'moves', len(m), 'law-bytes', sum(1 for cv in m if R[cv][sw][1] == R[cv]['vL'][1]), ' '.join(sorted(c.split('cases/')[-1] for c in m)))
