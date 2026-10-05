#!/usr/bin/env python3
# (v11u249) vgridsum.py <grid.txt>: per case-view: pristine -> law verdict (stage/cmplines/strict, rc), whether
# law + R11U249_OFF equals pristine's bytes, which switches move the law's bytes back, and the totals.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    p = l.split()
    if len(p) < 3: continue
    d = dict(x.split('=', 1) for x in p[2:] if '=' in x)
    d['raw'] = ' '.join(p[2:])
    rows[p[0]][p[1]] = d
def v(d):
    if not d: return 'NA'
    if 'cmp' not in d: return d['raw']
    s = d['strict']
    return f"cmp{d['cmplines']}/{s}/rc{d['rc']}"
def eq(d):
    return bool(d) and d.get('cmp') == '0' and d.get('cmplines') == '0' and d.get('strict', '').startswith('STRICT_EQUAL')
tot = collections.Counter()
for k in sorted(rows):
    r = rows[k]; P, L, O = r.get('pristine'), r.get('law'), r.get('lawOFF')
    off_ok = O and P and O.get('md5') == P.get('md5') and O.get('rc') == P.get('rc')
    tot['views'] += 1; tot['off_pristine'] += bool(off_ok)
    moved = P and L and (P.get('md5') != L.get('md5') or P.get('rc') != L.get('rc'))
    tot['moved'] += bool(moved)
    if eq(L) and not eq(P): tot['enter_SE'] += 1
    if eq(P) and not eq(L): tot['LEAVE_SE'] += 1
    sw = [t[4:].replace('R11U249_','').replace('_OFF','') for t in r if t.startswith('law-') and L and r[t].get('md5') != L.get('md5')]
    fx = ''
    if 'fix' in r: fx = f" fix={v(r['fix'])} fixOFF==law:{r.get('fixOFF',{}).get('md5')==(L or {}).get('md5')}"
    print(f"{k:45s} {'MOVE' if moved else '    '} P={v(P)} L={v(L)} off==P:{bool(off_ok)} sw:{','.join(sorted(sw))}{fx}")
print(dict(tot))
