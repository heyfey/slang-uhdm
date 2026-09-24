#!/usr/bin/env python3
"""probecols.py <base.tsv> <new.tsv>: per-case probe strict change classes (turned/fewer/moved/WORSE/MORE)."""
import sys, re
def load(p):
    d = {}
    for l in open(p):
        k, v = l.rstrip('\n').split('\t', 1); d[k] = v
    return d
def parse(v):
    if v.startswith('STRICT_EQUAL'): return ('equal', 0)
    m = re.match(r'STRICT_NOTEQUAL (\w+)\((\d+)\)', v)
    return (m.group(1), int(m.group(2))) if m else (v, -1)
a, b = load(sys.argv[1]), load(sys.argv[2]); tot = {}
for k in sorted(a):
    if a[k] == b.get(k): continue
    (fa, na), (fb, nb) = parse(a[k]), parse(b.get(k, 'MISSING'))
    if fb == 'equal': c = 'turned'
    elif fa == 'equal': c = 'WORSE'
    elif fa == fb: c = 'fewer' if nb < na else ('MORE' if nb > na else 'same')
    else: c = 'moved-fewer' if nb < na else ('moved-same' if nb == na else 'MOVED-MORE')
    tot[c] = tot.get(c, 0) + 1
    print(f'{c}\t{k}\t{a[k]}\t->\t{b.get(k)}')
print('TOTAL', ' '.join(f'{k}={v}' for k, v in sorted(tot.items())))
