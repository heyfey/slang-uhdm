#!/usr/bin/env python3
# r11u268 chains.py <classify outdir> <classify.txt>: per case, the first differing record's ancestor chain in the
# golden walk (type:name from the root down), and a bucket key (field | object type | parent | grandparent | top scope).
import os, re, sys, collections
od, txt = sys.argv[1:3]
rows = []
for l in open(txt):
    c = l.split()[0]; m = re.search(r'\| #(\d+) (\w+)', l)
    if not m: rows.append((c, '?', 'nomatch', '')); continue
    n, field = int(m.group(1)), m.group(2)
    k = os.path.join(od, c.replace('/', '__'))
    for side in ('a', 'b'):
        recs = [x.rstrip('\n').split('\t') for x in open(k + '.' + side)]
        if n < len(recs): break
    idx = n if n < len(recs) else len(recs) - 1
    # find record index: #N is 0-based?
    r = recs[idx]; d = int(r[0]); chain = [r]
    for j in range(idx - 1, -1, -1):
        if int(recs[j][0]) < d: chain.append(recs[j]); d = int(recs[j][0])
        if d == 0: break
    chain.reverse()
    key = f"{field}|{chain[-1][1]}|{chain[-2][1] if len(chain)>1 else ''}|{chain[-3][1] if len(chain)>2 else ''}|{chain[1][1] if len(chain)>1 else ''}"
    rows.append((c, field, key, ' > '.join(f'{x[1]}:{x[2]}' for x in chain)))
cnt = collections.Counter(r[2] for r in rows)
for c, f, k, ch in rows: print(c, '\t', k, '\t', ch)
print('=== buckets', file=sys.stderr)
for k, v in cnt.most_common(): print(v, k, file=sys.stderr)
