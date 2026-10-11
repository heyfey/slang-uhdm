#!/usr/bin/env python3
# v11u284 ctl3sum.py <controls3 file> <A> <B>: MOVE lines (md5 A != B) with rc, cmp lines and strict verdicts; totals.
import sys, collections
rows = collections.defaultdict(dict)
for ln in open(sys.argv[1]):
    f = ln.split(); kv = {}; vv = []
    for t in f[3:]:
        if '=' in t: k, v = t.split('=', 1); kv[k] = v
        else: vv.append(t)
    kv.setdefault('md5', 'NODB'); kv['v'] = ' '.join(vv); rows[(f[0], f[1])][f[2]] = kv
A, B = sys.argv[2:4]; mov = ent = lea = rcc = cmc = 0
for k in sorted(rows):
    a, b = rows[k][A], rows[k][B]
    if a['md5'] == b['md5']: continue
    mov += 1; e = 'STRICT_EQUAL' in b['v'] and 'STRICT_EQUAL' not in a['v']; l = 'STRICT_EQUAL' in a['v'] and 'STRICT_EQUAL' not in b['v']
    ent += e; lea += l; rcc += a['rc'] != b['rc']; cmc += a.get('cmp') != b.get('cmp')
    print('MOVE', *k, 'rc', a['rc'], '->', b['rc'], 'cmp', a.get('cmp'), '->', b.get('cmp'), '|', a['v'], '->', b['v'], '| ENTER' if e else '', '| LEAVE' if l else '')
print(f'{A}->{B}: case-views={len(rows)} moving={mov} entering={ent} leaving={lea} rc-changed={rcc} cmplines-changed={cmc}')
