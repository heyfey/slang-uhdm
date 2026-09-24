#!/usr/bin/env python3
# strictcols.py P.csv L.csv : row-by-row strict column change classification
import csv, sys, re
def load(p):
    d = {}
    for r in csv.DictReader(open(p, newline='')):
        d[(r['name'], r['mode'])] = (r['status'], r.get('strict', '') or '')
    return d
P, L = load(sys.argv[1]), load(sys.argv[2])
def parse(s):
    m = re.match(r'differ:(\w+)\((\d+)\)', s)
    return ('equal', 0) if s == 'equal' else ((m.group(1), int(m.group(2))) if m else (s, -1))
cls = {}; rows = {}
for k in sorted(set(P) | set(L)):
    p, l = P.get(k, ('ABSENT', '')), L.get(k, ('ABSENT', ''))
    if p[0] != l[0]: c = 'STATUS'
    elif p[1] == l[1]: c = 'same'
    else:
        pp, ll = parse(p[1]), parse(l[1])
        if ll[0] == 'equal': c = 'turned_equal'
        elif pp[0] == 'equal': c = 'WORSE_equal_to_differ'
        elif pp[0] == ll[0]: c = 'fewer' if ll[1] < pp[1] else ('MORE' if ll[1] > pp[1] else 'same')
        else: c = 'field_moved_fewer' if ll[1] < pp[1] else ('field_moved_SAMECOUNT' if ll[1] == pp[1] else 'field_moved_MORE')
    cls[c] = cls.get(c, 0) + 1
    if c != 'same': rows.setdefault(c, []).append((k, p[1], l[1]))
print(cls)
eq = lambda D: sum(1 for v in D.values() if v[1] == 'equal')
print('strict-equal P', eq(P), 'L', eq(L), 'judge-equal P', sum(1 for v in P.values() if v[0]=='CMP_EQUAL'))
for c in rows:
    if c in ('turned_equal', 'fewer', 'field_moved_fewer'): continue
    for k, a, b in rows[c]: print(c, k, a, '->', b)
if len(sys.argv) > 3:
    with open(sys.argv[3], 'w') as f:
        for c in rows:
            for k, a, b in rows[c]: f.write(f'{c}\t{k[0]}\t{k[1]}\t{a}\t{b}\n')
