#!/usr/bin/env python3
# (r11u280: copied from r11u278repro/drivers)
# r11u280 gridsum.py <grid.txt>: per case-view, pristine against the law: moved (database md5), entering / leaving
# STRICT_EQUAL, exit-code and uhdm-cmp line changes, R11U280_OFF equal to pristine, and the switch(es) that give
# pristine's bytes back for each mover.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(' ', 3)
    if len(w) < 4: continue
    rows[(w[0], w[1])][w[2]] = w[3].strip()
def f(s, k):
    m = re.search(k + r'=(\S+)', s); return m.group(1) if m else ''
def eq(s): return 'STRICT_EQUAL' in s
n = mov = ent = lea = rcc = cmpc = offeq = 0; attr = collections.Counter(); multi = []; lines = []
for (c, v), r in sorted(rows.items()):
    p, L = r.get('pristine', ''), r.get('law', ''); n += 1
    if f(r.get('law+R11U280_OFF', ''), 'md5') == f(p, 'md5'): offeq += 1
    if f(p, 'rc') != f(L, 'rc'): rcc += 1
    if f(p, 'cmp') != f(L, 'cmp'): cmpc += 1
    if f(p, 'md5') == f(L, 'md5'): continue
    mov += 1
    if eq(L) and not eq(p): ent += 1
    if eq(p) and not eq(L): lea += 1
    sws = [k[4:] for k in r if k.startswith('law+R11U280_') and k != 'law+R11U280_OFF' and f(r[k], 'md5') == f(p, 'md5')]
    for s in sws: attr[s] += 1
    if len(sws) != 1: multi.append(f'{c} {v} {sws}')
    vp = re.sub(r' md5=\S+', '', p); vl = re.sub(r' md5=\S+', '', L)
    lines.append(f'MOVER {c} {v}: {vp} -> {vl} [{",".join(sws)}]')
print('\n'.join(lines))
print(f'case-views {n}; moving {mov}; entering STRICT_EQUAL {ent}; leaving {lea}; exit-code changes {rcc}; '
      f'uhdm-cmp line changes {cmpc}; R11U280_OFF equal to pristine {offeq}/{n}')
print('restored by exactly one switch:', dict(attr), '; not exactly one:', multi)
