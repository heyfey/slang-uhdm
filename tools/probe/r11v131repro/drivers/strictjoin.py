#!/usr/bin/env python3
# strictjoin.py old.csv new.csv : row-by-row strict column transitions
import csv, sys, re, collections
def load(f):
    d = {}
    for r in csv.reader(open(f, newline='')):
        if not r or r[0] == 'name': continue
        r = [x.strip() for x in r]
        d[(r[0], r[1])] = (r[2], r[5] if len(r) > 5 else '')
    return d
A, B = load(sys.argv[1]), load(sys.argv[2])
cnt = collections.Counter(); rows = []
for k in sorted(set(A) | set(B)):
    a, b = A.get(k), B.get(k)
    if a is None or b is None: cnt['ONLY_ONE'] += 1; rows.append(('ONLY_ONE', k, a, b)); continue
    if a[0] != b[0]: cnt['STATUS'] += 1; rows.append(('STATUS', k, a, b)); continue
    if a[1] == b[1]: continue
    def p(s):
        m = re.match(r'differ:(\w+)\((\d+)\)', s); return (m.group(1), int(m.group(2))) if m else (s, 0)
    pa, pb = p(a[1]), p(b[1])
    if b[1] == 'equal': t = 'TO_EQUAL'
    elif a[1] == 'equal': t = 'WORSE_FROM_EQUAL'
    elif pa[0] == pb[0]: t = 'BETTER' if pb[1] < pa[1] else 'WORSE_MOREOBJ'
    else: t = 'FIELD_CHANGE'
    cnt[t] += 1; rows.append((t, k, a[1], b[1]))
for r in rows: print(*r)
print('SUMMARY', dict(cnt))
