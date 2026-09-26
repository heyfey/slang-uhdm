#!/usr/bin/env python3
# matrix.py <grid txt> : per case-mode pris/law/fix1 verdicts, order-blind distances, flags
import sys, collections, os, re
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    rows[f[0]][f[1]] = f[2:]
def C(p):
    if not os.path.exists(p): return None
    return collections.Counter('\t'.join(x.rstrip('\n').split('\t')[1:14]) for x in open(p, errors='replace'))
def dist(rel, t):
    g = C(f'/tmp/v11u178_g/{rel}/{t}.a.txt'); o = C(f'/tmp/v11u178_g/{rel}/{t}.b.txt')
    if g is None or o is None: return None
    return sum((o - g).values()) + sum((g - o).values())
def cmpl(v): return [x for x in v if x.startswith('cmplines=')][0] if any(x.startswith('cmplines=') for x in v) else v[0]
def st(v): return [x for x in v if x.startswith('strict=')][0][7:] if any(x.startswith('strict=') for x in v) else v[0]
n = 0; flags = 0
for rel in sorted(rows):
    r = rows[rel]; n += 1
    d = {t: dist(rel, t) for t in ('pris', 'law', 'fix1')}
    fl = []
    if cmpl(r['fix1']) != 'cmplines=0' and cmpl(r['pris']) == 'cmplines=0': fl.append('CMP_BREAK')
    if d['pris'] is not None and d['fix1'] is not None and d['fix1'] > d['pris']: fl.append('AWAY_FROM_PRIS')
    if d['law'] is not None and d['fix1'] is not None and d['fix1'] > d['law']: fl.append('AWAY_FROM_LAW')
    if st(r['pris']).startswith('STRICT_EQUAL') and not st(r['fix1']).startswith('STRICT_EQUAL'): fl.append('LEFT_EQUAL')
    if fl: flags += 1
    if fl or len(sys.argv) > 2:
        print(rel, 'pris', st(r['pris']), d['pris'], '| law', st(r['law']), d['law'], '| fix1', st(r['fix1']), d['fix1'], ' '.join(fl))
print('case-modes', n, 'flagged', flags)
conv = sum(1 for rel in rows if not st(rows[rel]['pris']).startswith('STRICT_EQUAL') and st(rows[rel]['fix1']).startswith('STRICT_EQUAL'))
convl = sum(1 for rel in rows if not st(rows[rel]['pris']).startswith('STRICT_EQUAL') and st(rows[rel]['law']).startswith('STRICT_EQUAL'))
print('conversions pris->law', convl, 'pris->fix1', conv)
