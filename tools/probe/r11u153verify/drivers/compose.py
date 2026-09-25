#!/usr/bin/env python3
# compose.py <swP> <swA> <swB> <swO> : the composition census. P = both landings on (d10675dd), A = pass 145 off
# (R11U145_OFF), B = pass 146 off (R11U146_OFF + R11U148_OFF), O = both off. For every row whose status or strict
# cell differs anywhere among the four, the per-sweep strict-differing object count (CMP_EQUAL -> 0) and a class:
#   ONLY145 / ONLY146   the row moves under one landing only (the other landing's switch leaves it)
#   JOINT               both landings move it; ADDITIVE when O-A and O-B both >= 0 and P <= min(A, B)
# Fail-closed: refuses without $FENCED; fenced rows are skipped.
#   SUSPECT             one landing alone moves the row AWAY from O (count or first field worse): the cancellation check
import csv, sys, re, collections, os
FENCED = set(os.environ.get('FENCED', '').split())
if len(FENCED) != 4: sys.exit('compose.py: export FENCED (the four slang-fenced names) first')
P, A, B, O = sys.argv[1:5]
def load(f, probe):
    d = {}
    for r in csv.reader(open(f)):
        if not r or r[0] in ('name', 'case'): continue
        if probe: d[(r[0],)] = (r[1], r[3] if len(r) > 3 else '')
        else: d[(r[0], r[1])] = (r[2], r[5] if len(r) > 5 else '')
    return d
def cnt(v):
    if v is None: return None
    st, sx = v
    if st in ('CMP_EQUAL', 'EQUAL'): return 0
    m = re.match(r'differ:(\w+)\((\d+)\)', sx or '')
    return int(m.group(2)) if m else None
tot = collections.Counter()
for corpus, probe in (('probe', True), ('surelog', False), ('uhdm2rtlil', False)):
    S = [load(f'{w}/{corpus}.csv', probe) for w in (P, A, B, O)]
    keys = sorted(set().union(*S))
    for k in keys:
        v = [s.get(k) for s in S]
        if len(set(map(str, v))) == 1: continue
        if k[0] in FENCED: continue
        c = [cnt(x) for x in v]
        p, a, b, o = c
        m145 = v[1] != v[0]; m146 = v[2] != v[0]
        if None in c: cls = 'NOCOUNT'
        elif (a > o) or (b > o): cls = 'SUSPECT'
        elif m145 and m146: cls = 'JOINT-ADDITIVE' if p <= min(a, b) and (o - a) >= 0 and (o - b) >= 0 else 'JOINT-OTHER'
        elif m145: cls = 'ONLY145'
        elif m146: cls = 'ONLY146'
        else: cls = 'OTHER'
        conv = 'CONV' if v[0][0] in ('CMP_EQUAL', 'EQUAL') and v[3][0] not in ('CMP_EQUAL', 'EQUAL') else 'chg'
        tot[(corpus, conv, cls)] += 1
        print(corpus, '/'.join(k), conv, cls, 'P=%s A=%s B=%s O=%s' % tuple(x[1] if x and x[1] else (x[0] if x else '-') for x in v), sep='\t')
for k, n in sorted(tot.items()): print('#', *k, n, sep='\t', file=sys.stderr)
