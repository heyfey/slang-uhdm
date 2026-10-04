#!/usr/bin/env python3
# gridcmp.py <grid file> <tagA> <tagB>: per case-view, the verdict under A and B (from case.sh lines); prints the
# moves (verdict or md5) and a tally: entering STRICT_EQUAL, leaving it, leaving judge-equality, entering it, rc changes.
import sys, re, collections
f, A, B = sys.argv[1:4]
v = collections.defaultdict(dict)
for l in open(f):
    p = l.split()
    if len(p) < 3: continue
    d = dict(x.split('=', 1) for x in p[2:] if '=' in x)
    st = d.get('strict', p[2] if len(p) > 2 else '?')
    if 'SURELOG_FAIL' in l: st = 'SURELOG_FAIL'
    elif 'SLANG_FAIL' in l: st = 'SLANG_FAIL'
    v[p[0]][p[1]] = (st, d.get('md5', '-'), d.get('rc', '-'))
def cls(s):
    if s.startswith('STRICT_EQUAL'): return 'EQ'
    if s.startswith('STRICT_NOTEQUAL'): return 'SNE'
    if s.startswith('NOT_EQUAL'): return 'NE'
    return s
t = collections.Counter()
for k in sorted(v):
    if A not in v[k] or B not in v[k]: t['missing'] += 1; continue
    a, b = v[k][A], v[k][B]
    ca, cb = cls(a[0]), cls(b[0])
    if a[2] != b[2]: t['rc_change'] += 1; print('RC', k, a[2], '->', b[2])
    if a[1] == b[1]: t['same_bytes'] += 1; continue
    t['moved'] += 1
    tag = 'same' if a[0] == b[0] else f'{ca}->{cb}'
    if a[0] != b[0]: print('MOVE', k, a[0], '->', b[0])
    if ca != 'EQ' and cb == 'EQ': t['enter_EQ'] += 1
    if ca == 'EQ' and cb != 'EQ': t['leave_EQ'] += 1
    if ca in ('EQ', 'SNE') and cb not in ('EQ', 'SNE'): t['leave_judge_equal'] += 1
    if ca not in ('EQ', 'SNE') and cb in ('EQ', 'SNE'): t['enter_judge_equal'] += 1
    if a[0] != b[0] and ca == cb == 'SNE': t['sne_detail_change'] += 1
print('TALLY', ' '.join(f'{k}={t[k]}' for k in sorted(t)))
