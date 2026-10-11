#!/usr/bin/env python3
# v11u284 gsum.py <grid file>: per case-view, pristine vs law (rc, cmp lines, strict verdict, md5), the movers,
# entering/leaving STRICT_EQUAL, and which switch restores pristine's md5 (attribution).
import sys, collections
rows = collections.defaultdict(dict)
for ln in open(sys.argv[1]):
    f = ln.split()
    case, view, lab = f[0], f[1], f[2]
    kv = {}; verdict = []
    for t in f[3:]:
        if '=' in t: k, v = t.split('=', 1); kv[k] = v
        else: verdict.append(t)
    kv['v'] = ' '.join(verdict); rows[(case, view)][lab] = kv
mov = ent = lea = rcch = cmpch = offbad = 0
for key in sorted(rows):
    r = rows[key]; p, l = r['pristine'], r['law']
    if r['law+R11U284_OFF'].get('md5') != p.get('md5'): offbad += 1; print('OFF!=PRIS', *key)
    if p.get('md5') == l.get('md5'): continue
    mov += 1
    sw = [k[4:] for k in r if k.startswith('law+R11U284_') and k != 'law+R11U284_OFF' and r[k].get('md5') == p.get('md5')]
    e = 'STRICT_EQUAL' in l['v'] and 'STRICT_EQUAL' not in p['v']
    lv = 'STRICT_EQUAL' in p['v'] and 'STRICT_EQUAL' not in l['v']
    ent += e; lea += lv
    if p.get('rc') != l.get('rc'): rcch += 1
    if p.get('cmp') != l.get('cmp'): cmpch += 1
    print('MOVE', *key, 'rc', p.get('rc'), '->', l.get('rc'), 'cmp', p.get('cmp'), '->', l.get('cmp'), '|', p['v'], '->', l['v'], '| sw', ','.join(sw) or 'NONE', '| ENTER' if e else '', '| LEAVE' if lv else '')
print(f'views={len(rows)} moving={mov} entering={ent} leaving={lea} rc_changes={rcch} cmp_changes={cmpch} off_not_pristine={offbad}')
