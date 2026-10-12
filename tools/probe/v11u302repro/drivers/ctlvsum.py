#!/usr/bin/env python3
# v11u302 ctlvsum.py <ctl.txt>: summary of ctlv.sh's three-binary byte controls: case-views, NOGOLDEN, then for law and
# fix against pristine the movers (MOVER lines), entering / leaving STRICT_EQUAL, rc and uhdm-cmp changes, and fix vs law.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.rstrip('\n').split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3]
f = lambda s, k: (re.search(k + r'=(\S+)', s) or [None, ''])[1]
vd = lambda s: ' '.join(x for x in s.split() if not x.startswith('md5='))
t = collections.Counter()
for (c, v), r in sorted(rows.items()):
    p, L, F = r.get('pristine', ''), r.get('law', ''), r.get('fix', '')
    t['views'] += 1
    if 'NOGOLDEN' in p: t['nogolden'] += 1; continue
    for tag, x in (('law', L), ('fix', F)):
        if f(x, 'rc') != f(p, 'rc'): t[tag + '_rc'] += 1; print('RC', tag, c, v, f(p, 'rc'), f(x, 'rc'))
        if f(x, 'cmp') != f(p, 'cmp'): t[tag + '_cmp'] += 1; print('CMP', tag, c, v, f(p, 'cmp'), f(x, 'cmp'))
        if f(x, 'md5') != f(p, 'md5'):
            t[tag + '_movers'] += 1; t[tag + '_enter'] += ('STRICT_EQUAL' in x and 'STRICT_EQUAL' not in p); t[tag + '_leave'] += ('STRICT_EQUAL' in p and 'STRICT_EQUAL' not in x)
            if tag == 'fix': print(f'MOVER {c} {v}: {vd(p)} -> {vd(x)}')
    if f(F, 'md5') != f(L, 'md5'): t['fix_vs_law'] += 1; print('FIXvsLAW', c, v, vd(L), '->', vd(F))
print(' '.join(f'{k}={t[k]}' for k in sorted(t)))
