#!/usr/bin/env python3
"""strictdiff.py A.csv B.csv — row-mode join of two sweep csvs on (name,mode);
prints every row whose status or strict column differs, classified:
TO-EQUAL (differ->equal), WORSE (equal->differ, or same first field with more
objects, or a different first field), BETTER (same field, fewer objects), STATUS."""
import csv, re, sys
def load(p):
    d = {}
    with open(p) as f:
        for r in csv.DictReader(f):
            d[(r['name'], r['mode'])] = (r['status'], r.get('strict', '') or '')
    return d
a, b = load(sys.argv[1]), load(sys.argv[2])
cnt = {}
for k in sorted(set(a) | set(b)):
    sa, sb = a.get(k, ('ABSENT', '')), b.get(k, ('ABSENT', ''))
    if sa == sb:
        continue
    if sa[0] != sb[0]:
        cls = 'STATUS'
    elif sb[1] == 'equal':
        cls = 'TO-EQUAL'
    elif sa[1] == 'equal':
        cls = 'WORSE'
    else:
        ma = re.match(r'differ:(\w+)\((\d+)\)', sa[1]); mb = re.match(r'differ:(\w+)\((\d+)\)', sb[1])
        if ma and mb and ma.group(1) == mb.group(1):
            cls = 'BETTER' if int(mb.group(2)) < int(ma.group(2)) else 'WORSE'
        else:
            cls = 'FIELD-CHANGE'
    cnt[cls] = cnt.get(cls, 0) + 1
    print(f'{cls}\t{k[0]}/{k[1]}\t{sa[0]}:{sa[1]}\t->\t{sb[0]}:{sb[1]}')
print('SUMMARY ' + ' '.join(f'{k}={v}' for k, v in sorted(cnt.items())))
