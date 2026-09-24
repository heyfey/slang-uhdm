#!/usr/bin/env python3
# strictcmp_cols.py <wdA> <wdB>: row-by-row strict column diff (both corpora)
import sys, csv, re
A, B = sys.argv[1], sys.argv[2]
def load(p):
    d = {}
    for r in csv.reader(open(p)):
        if len(r) >= 6 and r[0] != 'name': d[(r[0], r[1])] = (r[2], r[5])
    return d
def cnt(s):
    m = re.match(r'differ:(\w+)\((\d+)\)', s)
    return (m.group(1), int(m.group(2))) if m else (s, 0)
tot = {'better': 0, 'worse': 0, 'same': 0, 'moved': 0}
for c in ('surelog', 'uhdm2rtlil'):
    a, b = load(f'{A}/{c}.csv'), load(f'{B}/{c}.csv')
    for k in sorted(set(a) | set(b)):
        sa, sb = a.get(k, ('ABSENT', '')), b.get(k, ('ABSENT', ''))
        if sa == sb: tot['same'] += 1; continue
        if sa[0] != sb[0]: kind = 'STATUS'
        elif sb[1] == 'equal': kind = 'BETTER'
        elif sa[1] == 'equal': kind = 'WORSE'
        else:
            fa, na = cnt(sa[1]); fb, nb = cnt(sb[1])
            kind = 'MOVED' if fa != fb else ('FEWER' if nb < na else 'MORE')
        print(f'{kind}\t{c}\t{k[1]}\t{k[0]}\t{sa[1]}\t->\t{sb[1]}')
