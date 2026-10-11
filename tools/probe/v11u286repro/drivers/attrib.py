#!/usr/bin/env python3
# v11u286 attrib.py <evidence dir>: reads gridall_{pristine,law,off,sw_<X>}.txt; prints the OFF-vs-pristine check, the
# movers (pristine vs law, by md5) with their status change and the switch(es) that restore pristine's bytes, and
# the exit-code / leave census.
import sys, glob, os, re, collections
E = sys.argv[1]
def load(f):
    d = {}
    for l in open(f):
        w = l.split()
        k = (w[0], w[1]); md = [x for x in w if x.startswith('md5=')]
        rc = [x for x in w if x.startswith('rc=')]
        st = ' '.join(w[3:]).split(' md5=')[0]
        d[k] = (md[0] if md else 'nodb', rc[0] if rc else 'rc=?', st)
    return d
P = load(f'{E}/gridall_pristine.txt'); L = load(f'{E}/gridall_' + (sys.argv[2] if len(sys.argv) > 2 else 'law') + '.txt'); O = load(f'{E}/gridall_off.txt')
S = {re.sub(r'.*gridall_sw_(.*)\.txt', r'\1', f): load(f) for f in sorted(glob.glob(f'{E}/gridall_sw_*.txt'))}
print('case-views', len(P), 'off==pristine', sum(O[k][0] == P[k][0] for k in P), 'rc differing', sum(L[k][1] != P[k][1] for k in P))
mv = [k for k in P if P[k][0] != L[k][0]]
ent = sum('STRICT_EQUAL' in L[k][2] and 'STRICT_EQUAL' not in P[k][2] for k in mv)
lv = sum('STRICT_EQUAL' in P[k][2] and 'STRICT_EQUAL' not in L[k][2] for k in P)
print('moving', len(mv), 'entering STRICT_EQUAL', ent, 'leaving', lv)
cnt = collections.Counter()
for k in sorted(mv):
    sw = [s for s in S if S[s][k][0] == P[k][0]]
    cnt['+'.join(sw) or 'NONE'] += 1
    print('MOVER', k[0], k[1], P[k][2], '->', L[k][2], 'switch=' + ('+'.join(sw) or 'NONE'))
print('attribution', dict(cnt))
