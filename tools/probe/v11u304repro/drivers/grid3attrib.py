#!/usr/bin/env python3
# v11u304 grid3attrib.py <grid3.txt>: for every fix mover (fix md5 != pristine md5), the single R11U304_* switches
# whose fix+<switch> line gives pristine's bytes back; counts per acting law ('several' = no single switch does).
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.rstrip('\n').split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3]
md5 = lambda s: (re.search(r'md5=(\S+)', s) or [None, ''])[1]
cnt = collections.Counter()
for (c, v), r in sorted(rows.items()):
    p = md5(r['pristine'])
    if md5(r['fix']) == p: continue
    sw = [k[4:].replace('R11U304_', '').replace('_OFF', '') for k in r if k.startswith('fix+R11U304_') and k != 'fix+R11U304_OFF' and md5(r[k]) == p]
    key = ' '.join(sorted(sw)) if sw else 'several'
    cnt[key] += 1
    if not sw or len(sw) > 1: print('ATTRIB', c, v, key)
print('fix movers by single law switch:', dict(cnt))
