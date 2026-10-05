#!/usr/bin/env python3
# vgridsum.py <grid.txt>: per case-view, pristine vs law (verdict, cmp lines, rc), OFF == pristine bytes, each switch == pristine bytes.
import sys, collections
rows = collections.OrderedDict()
for l in open(sys.argv[1]):
    f = l.split()
    if len(f) < 3: continue
    d = dict(x.split('=', 1) for x in f[2:] if '=' in x)
    d['raw'] = ' '.join(f[2:])
    rows.setdefault(f[0], {})[f[1]] = d
def v(d):
    if 'strict' not in d: return d['raw']
    return '%s/%s/rc%s' % (d['strict'].replace('STRICT_EQUAL_', 'EQ').replace('NOT_EQUAL_', 'NE_'), d['cmplines'], d['rc'])
enter = leave = move = offbad = swbad = 0
for k, r in rows.items():
    p, L = r.get('pristine', {}), r.get('law', {})
    mv = p.get('md5') != L.get('md5')
    move += mv
    pe = p.get('strict', '').startswith('STRICT_EQUAL'); le = L.get('strict', '').startswith('STRICT_EQUAL')
    enter += (le and not pe); leave += (pe and not le)
    off = r.get('lawOFF', {}).get('md5') == p.get('md5')
    offbad += not off
    sws = [t for t in r if t.startswith('law-')]
    swok = all(r[t].get('md5') == p.get('md5') for t in sws) if len(sws) == 1 else None
    if mv and len(sws) == 1 and not swok: swbad += 1
    print('%-40s %s %-28s -> %-28s off=%s sw=%s' % (k, 'MOVE' if mv else '    ', v(p), v(L), 'ok' if off else 'BAD',
          {t[12:]: ('pris' if r[t].get('md5') == p.get('md5') else 'law' if r[t].get('md5') == L.get('md5') else 'other') for t in sws}))
print('case-views %d moved %d enter %d leave %d offbad %d swbad(single-switch) %d' % (len(rows), move, enter, leave, offbad, swbad))
