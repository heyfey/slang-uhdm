#!/usr/bin/env python3
# r10v69 - VALIDATE the implementer's python mirror against the REAL binaries:
# mirror(pristine census) must equal the PATCHED census name, cell for cell.
# If they agree everywhere, the mirror's golden-cache "fixed point" claim is
# a trustworthy statement about the SHIPPED C++ helper.
import sys, collections, types

import os
MIR = os.environ.get('HPFOLD69', os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r10earl69repro', 'hpfold69.py'))
m = types.ModuleType('m')
_src = open(MIR).read()
_src = _src.replace("\nmain()", "\n")
exec(compile(_src, 'hpfold69', 'exec'), m.__dict__)


def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        f = l.rstrip('\n').split(' ')
        if not f or f[0] != 'HP':
            continue
        kv = {}
        for x in f[5:]:
            if '=' in x:
                k, v = x.split('=', 1)
                kv.setdefault(k, v)
        d[(f[1], f[2], f[3], f[4])].append((kv.get('name', ''), f[-1]))
    return d


P, Q = load(sys.argv[1]), load(sys.argv[2])
ok = bad = miss = 0
ex = []
for k in P:
    A = sorted(P[k])
    B = sorted(Q.get(k, []))
    if len(A) != len(B):
        miss += max(len(A), len(B))
        continue
    for a, b in zip(A, B):
        pred = m.rewrite(a[0], m.parse_elems(a[1]))
        if pred == b[0]:
            ok += 1
        else:
            bad += 1
            if len(ex) < 8:
                ex.append((k, a[0], pred, b[0]))
print('MIRROR-vs-BINARY agree %d disagree %d unkeyed %d' % (ok, bad, miss))
for e in ex:
    print('    ', e[0][0], e[0][2], '| pris', e[1], '| mirror', e[2], '| real', e[3])
