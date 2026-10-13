#!/usr/bin/env python3
# (v11u317: copied from r11u317repro/drivers; rel maps v11u317repro/cases to v/)
# (r11u317: copied from v11u315repro/drivers)
# (r11u315: copied from r11u313repro/drivers)
# (r11u313: copied from v11u311repro/drivers)
# (v11u311: copied from r11u311repro/drivers)
# (r11u311: copied from r11u309repro/drivers)
# r11u313 (from r11u311, r11u309): summarise drivers/grid.sh output. Per case-view: pristine vs law verdict, moved or not, R11U317_OFF == pristine
# bytes, and the switches that each restore pristine's bytes alone. Usage: gridsum315.py evidence/grid.txt
import sys, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 4:
        continue
    tag, cv = f[0], f[1]
    kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
    rows[cv][tag] = kv
mv = ent = leave = offok = 0; attr = collections.Counter(); multi = []
for cv in sorted(rows):
    r = rows[cv]; P = r.get('P', {}); L = r.get('L', {})
    if not P or not L:
        print('MISSING', cv); continue
    moved = P.get('md5') != L.get('md5')
    ps, ls = P.get('strict', P.get('rc')), L.get('strict', L.get('rc'))
    if r.get('OFF', {}).get('md5') == P.get('md5'):
        offok += 1
    sw = [t for t in r if t.startswith('R11U317_') and r[t].get('md5') == P.get('md5')]
    if moved:
        mv += 1
        e = 'STRICT_EQUAL' in (ls or '') and 'STRICT_EQUAL' not in (ps or '')
        lv = 'STRICT_EQUAL' in (ps or '') and 'STRICT_EQUAL' not in (ls or '')
        ent += e; leave += lv
        if len(sw) == 1: attr[sw[0]] += 1
        else: multi.append(cv)
        print(f"MOVE {cv} P={ps} rcP={P.get('rc')} L={ls} rcL={L.get('rc')} cmplines {P.get('cmplines')}->{L.get('cmplines')} restore={','.join(sw) or 'pair'}")
    else:
        print(f"SAME {cv} {ps} rc={P.get('rc')}")
print(f"case-views {len(rows)} moving {mv} entering {ent} leaving {leave} OFF==pristine {offok}")
print('single-switch', dict(attr)); print('pair-or-more', len(multi), ' '.join(multi))
