#!/usr/bin/env python3
# r11u307 gridsum307.py <grid.txt>: per case-view P vs L, OFF == P check, and which single switch restores P md5.
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    cfg, cv = f[0], f[1]
    d = dict(x.split('=',1) for x in f[3:] if '=' in x)
    rows[cv][cfg] = d
sw = ['R11U307_NESTREPDEF_OFF','R11U307_DEEPSTUB_OFF','R11U307_POSUDP_OFF','R11U307_DEFGENUDP_OFF','R11U307_DEFGENORD_OFF','R11U307_GENMODARR_OFF']
mov = ent = leave = offbad = rcchg = 0
attr = collections.Counter(); multi = []
for cv in sorted(rows):
    r = rows[cv]; P, L, O = r['P'], r['L'], r['OFF']
    if O.get('md5') != P.get('md5') or O.get('rc') != P.get('rc'): offbad += 1; print('OFF!=P', cv)
    if P.get('rc') != L.get('rc'): rcchg += 1
    if P.get('md5') == L.get('md5'): continue
    mov += 1
    ps, ls = P.get('strict',''), L.get('strict','')
    if ls.startswith('STRICT_EQUAL') and not ps.startswith('STRICT_EQUAL'): ent += 1
    if ps.startswith('STRICT_EQUAL') and not ls.startswith('STRICT_EQUAL'): leave += 1; print('LEAVE', cv)
    rest = [s for s in sw if r[s].get('md5') == P.get('md5')]
    if len(rest) == 1: attr[rest[0]] += 1
    else:
        multi.append((cv, rest))
print(f'case-views {len(rows)} moving {mov} entering STRICT_EQUAL {ent} leaving {leave} OFF!=P {offbad} rc changes {rcchg}')
print('restored by exactly one switch:', dict(attr))
for cv, rest in multi: print('not single-switch:', cv, rest)
