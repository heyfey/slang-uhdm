#!/usr/bin/env python3
# v11u284 g3sum.py <grid3 file> <A label> <B label>: case-views whose md5 moves from A to B, with rc, cmp lines and
# strict verdicts, entering/leaving STRICT_EQUAL, and which fix switches restore A (for law -> fix attribution);
# checks fix+R11U284_OFF == pristine and fix+R11V284_OFF == law on every view.
import sys, collections
rows = collections.defaultdict(dict)
for ln in open(sys.argv[1]):
    f = ln.split(); kv = {}; vv = []
    for t in f[3:]:
        if '=' in t: k, v = t.split('=', 1); kv[k] = v
        else: vv.append(t)
    kv.setdefault('md5', 'NODB'); kv['v'] = ' '.join(vv); rows[(f[0], f[1])][f[2]] = kv
A, B = sys.argv[2], sys.argv[3]
mov = ent = lea = rcch = cmpch = 0; offp = offl = 0
for key in sorted(rows):
    r = rows[key]
    if r['fix+R11U284_OFF']['md5'] != r['pristine']['md5']: offp += 1; print('U284OFF!=PRIS', *key)
    if r['fix+R11V284_OFF']['md5'] != r['law']['md5']: offl += 1; print('V284OFF!=LAW', *key)
    a, b = r[A], r[B]
    if a['md5'] == b['md5']: continue
    mov += 1
    e = 'STRICT_EQUAL' in b['v'] and 'STRICT_EQUAL' not in a['v']; l = 'STRICT_EQUAL' in a['v'] and 'STRICT_EQUAL' not in b['v']
    ent += e; lea += l; rcch += a['rc'] != b['rc']; cmpch += a.get('cmp') != b.get('cmp')
    sw = [k[4:] for k in r if k.startswith('fix+R11V284_') and k != 'fix+R11V284_OFF' and r[k]['md5'] == r['law']['md5']]
    print('MOVE', *key, 'rc', a['rc'], '->', b['rc'], 'cmp', a.get('cmp'), '->', b.get('cmp'), '|', a['v'], '->', b['v'], '| lawsw', ','.join(sw) or '-', '| ENTER' if e else '', '| LEAVE' if l else '')
print(f'{A}->{B}: views={len(rows)} moving={mov} entering={ent} leaving={lea} rc_changes={rcch} cmp_changes={cmpch} U284OFF!=pristine={offp} V284OFF!=law={offl}')
