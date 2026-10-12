#!/usr/bin/env python3
# (r11u286: copied from r11u284repro/drivers; R11U286_* switches, R11U286_TRACE)
# r11u286 (copied from r11u284repro; r11u284 copied from r11u282repro) gridsum.py  <gridall.txt>: per case-view the pristine / law / law+R11U292_OFF lines; prints the movers
# (pristine md5 != law md5) as `MOVER <case> <view>: <pristine verdict> -> <law verdict>`, then the totals:
# case-views, movers, entering / leaving STRICT_EQUAL, exit-code changes, uhdm-cmp line changes, and the
# R11U292_OFF byte check (law+R11U292_OFF md5 == pristine md5).
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.rstrip('\n').split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3]
f = lambda s, k: (re.search(k + r'=(\S+)', s) or [None, ''])[1]
verdict = lambda s: ' '.join(x for x in s.split() if not x.startswith(('md5=', 'rc=', 'cmp=')))
n = mv = ent = lv = rcch = cmpch = offok = 0
for (c, v), r in sorted(rows.items()):
    p, L, O = r.get('pristine', ''), r.get('law', ''), r.get('law+R11U292_OFF', '')
    n += 1
    offok += f(O, 'md5') == f(p, 'md5')
    if f(p, 'rc') != f(L, 'rc'): rcch += 1; print('RC', c, v, f(p, 'rc'), '->', f(L, 'rc'))
    if f(p, 'cmp') != f(L, 'cmp'): cmpch += 1; print('CMP', c, v, f(p, 'cmp'), '->', f(L, 'cmp'))
    if f(p, 'md5') == f(L, 'md5'): continue
    mv += 1
    pe, le = 'STRICT_EQUAL' in p, 'STRICT_EQUAL' in L
    ent += (le and not pe); lv += (pe and not le)
    print(f'MOVER {c} {v}: {verdict(p)} -> {verdict(L)}')
print(f'case-views={n} movers={mv} entering_STRICT_EQUAL={ent} leaving_STRICT_EQUAL={lv} rc_changes={rcch} cmp_changes={cmpch} OFF_equals_pristine={offok}/{n}')
