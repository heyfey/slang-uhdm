#!/usr/bin/env python3
# r11u280 attrib.py <grid.txt>: per moving case-view (pristine md5 != law md5), the switches whose single-off run
# changes the law's bytes (the laws that act on that case-view), and whether all of them off together is pristine
# (R11U280_OFF row).  Complements gridsum.py's exactly-one-switch attribution for case-views two laws act on.
import sys, re, collections
rows = collections.defaultdict(dict)
for l in open(sys.argv[1]):
    w = l.split(' ', 3)
    if len(w) == 4: rows[(w[0], w[1])][w[2]] = w[3].strip()
md5 = lambda s: (re.search(r'md5=(\S+)', s) or [None, ''])[1]
combo = collections.Counter()
for (c, v), r in sorted(rows.items()):
    p, L = md5(r.get('pristine', '')), md5(r.get('law', ''))
    if p == L: continue
    acts = [k[4:].replace('R11U280_', '').replace('_OFF', '') for k in r
            if k.startswith('law+R11U280_') and k != 'law+R11U280_OFF' and md5(r[k]) != L]
    combo['+'.join(sorted(acts))] += 1
    print(f'{c} {v} acting: {"+".join(sorted(acts))} all-off-pristine: {md5(r.get("law+R11U280_OFF","")) == p}')
print('acting-law sets over the movers:', dict(combo))
