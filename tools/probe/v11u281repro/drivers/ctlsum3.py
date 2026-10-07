#!/usr/bin/env python3
# v11u281 ctlsum3.py <controls.txt>: pristine -> law and pristine -> fix and law -> fix over every case-view: moving,
# entering / leaving STRICT_EQUAL, exit-code and uhdm-cmp line-count changes; mover lists (MOVE_<pair> lines).
import sys, collections
r = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    x = l.split()
    if len(x) < 3: continue
    r[x[0]][x[1]] = dict(y.split('=', 1) for y in x[2:] if '=' in y)
eq = lambda k: k.get('cmp') == '0' and 'STRICT_EQUAL' in k.get('strict', '')
for a, b in (('pristine', 'law'), ('pristine', 'fix'), ('law', 'fix')):
    st = collections.Counter()
    for cv, d in sorted(r.items()):
        if a not in d or b not in d: st['missing'] += 1; continue
        A, B = d[a], d[b]; st['views'] += 1
        if A.get('md5') == B.get('md5'): continue
        st['moving'] += 1; st['entering'] += (not eq(A)) and eq(B); st['leaving'] += eq(A) and not eq(B)
        st['rc'] += A.get('rc') != B.get('rc'); st['cmplines'] += A.get('cmplines') != B.get('cmplines')
        print(f'MOVE_{a}_{b} {cv} {A.get("strict")} -> {B.get("strict")} cmplines {A.get("cmplines")}->{B.get("cmplines")} rc {A.get("rc")}->{B.get("rc")}')
    print(f'SUMMARY {a}->{b}', dict(st))
