#!/usr/bin/env python3
# v11u273 vgridsum.py <vgrid lines>...: per case-view, P -> L and P -> F movement (STRICT_EQUAL entering/leaving,
# uhdm-cmp line and exit-code changes), VOFF == L and UOFF == P byte checks, and each F-vs-L mover attributed to
# the single R11V273 switch that gives L's bytes back.
import sys, collections
rows = collections.defaultdict(dict)
for f in sys.argv[1:]:
    for l in open(f):
        p = l.split()
        if len(p) < 4: continue
        d = dict(x.split('=', 1) for x in p[3:] if '=' in x); d['st'] = p[2]
        rows[p[1]][p[0]] = d
rank = lambda s: 2 if s.startswith('STRICT_EQUAL') else 1 if s.startswith('STRICT_NOTEQUAL') else 0
st = collections.Counter()
for c in sorted(rows):
    r = rows[c]; P, L, F = r['P'], r['L'], r['F']
    if 'md5' not in P:
        st['no_db'] += 1
        print('NODB', c, P['st'], 'rc', P.get('rc'), L.get('rc'), F.get('rc')); continue
    if r['VOFF'].get('md5') != L['md5']: st['voff_bad'] += 1; print('VOFF!=L', c)
    if r['UOFF'].get('md5') != P['md5']: st['uoff_bad'] += 1; print('UOFF!=P', c)
    for t, X in (('L', L), ('F', F)):
        if X['md5'] == P['md5']: continue
        st[t + '_move'] += 1
        a, b = P['strict'], X['strict']
        if rank(b) == 2 and rank(a) < 2: st[t + '_enter'] += 1
        if rank(b) < rank(a): st[t + '_leave'] += 1
        if P['cmplines'] != X['cmplines']: st[t + '_cmpchg'] += 1
        if P['rc'] != X['rc']: st[t + '_rcchg'] += 1
    if F['md5'] != L['md5']:
        sw = [k for k in r if k.startswith('R11V273_') and r[k].get('md5') == L['md5']]
        st['F_vs_L'] += 1
        print('FvsL', c, 'P', P['strict'], 'L', L['strict'], 'F', F['strict'], 'by', ','.join(sw) or 'NONE')
    lsw = [k for k in r if k.startswith('R11U273_') and r[k].get('md5') != F['md5']]
    if F['md5'] != P['md5']: print('MOVE', c, P['strict'], '->', F['strict'], 'law-switches:', ','.join(lsw))
print(len(rows), 'case-views', dict(st))
