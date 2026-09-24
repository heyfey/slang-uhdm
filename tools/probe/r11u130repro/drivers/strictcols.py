#!/usr/bin/env python3
"""strictcols.py <base csv> <new csv> [...pairs]: row-by-row join (name,mode) of the strict column.
Prints every changed row and a verdict class: turned (differ->equal), fewer/more (same first field,
object count), moved (first field changed), worse (equal->differ), status (status changed)."""
import sys, csv, re
def load(p):
    d = {}
    with open(p, newline='') as f:
        for r in csv.reader(f):
            if not r or r[0] == 'name': continue
            r = [x.strip() for x in r]
            while len(r) < 6: r.append('')
            d[(r[0], r[1])] = (r[2], r[5])
    return d
def cnt(s):
    m = re.match(r'differ:(\w+)\((\d+)\)', s)
    return (m.group(1), int(m.group(2))) if m else (None, None)
args = sys.argv[1:]
tot = {}
for i in range(0, len(args), 2):
    a, b = load(args[i]), load(args[i+1])
    for k in sorted(set(a) & set(b)):
        (sa, xa), (sb, xb) = a[k], b[k]
        if sa != sb: cls = 'status'
        elif xa == xb: continue
        elif sa != 'CMP_EQUAL': cls = 'noncmp'
        elif xb == 'equal': cls = 'turned'
        elif xa == 'equal': cls = 'WORSE'
        else:
            fa, na = cnt(xa); fb, nb = cnt(xb)
            if fa == fb: cls = 'fewer' if nb < na else ('MORE' if nb > na else 'same')
            else: cls = 'moved-fewer' if nb < na else ('moved-same' if nb == na else 'MOVED-MORE')
        tot[cls] = tot.get(cls, 0) + 1
        print(f'{cls}\t{k[0]},{k[1]}\t{sa} {xa}\t->\t{sb} {xb}')
    for k in sorted(set(a) ^ set(b)):
        print(f'ONLY-ONE-SIDE\t{k}')
print('TOTAL', ' '.join(f'{k}={v}' for k, v in sorted(tot.items())))
