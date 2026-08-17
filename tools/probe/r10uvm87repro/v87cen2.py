#!/usr/bin/env python3
import re, sys, collections
OBJ = re.compile(r'^(\s*)\\_([a-zA-Z_]+): (\(([^)]*)\))?')
def census(path):
    out = collections.defaultdict(collections.Counter)
    stack = []
    for line in open(path, errors='replace'):
        m = OBJ.match(line.rstrip('\n'))
        if not m: continue
        ind = len(m.group(1)); kind = m.group(2); nm = m.group(4) or ''
        while stack and stack[-1][0] >= ind: stack.pop()
        if kind == 'class_typespec':
            p = '/'.join(x[1] for x in stack[-3:])
            out[p][nm] += 1
        stack.append((ind, f'{kind}({nm})'))
    return out
g, p, a = (census(f) for f in sys.argv[1:4])
keys = sorted(set(g) | set(p) | set(a))
nreg = nfix = 0
for k in keys:
    gs, ps, as_ = g.get(k, collections.Counter()), p.get(k, collections.Counter()), a.get(k, collections.Counter())
    if ps == as_: continue
    tag = ''
    if gs and ps == gs and as_ != gs: tag = 'REGRESSION'; nreg += 1
    elif gs and ps != gs and as_ == gs: tag = 'FIXED'; nfix += 1
    elif not gs: tag = 'NO-GOLDEN-PATH'
    else: tag = 'CHANGED'
    print(f'{tag:15s} {k}\n   G={dict(gs)}\n   P={dict(ps)}\n   A={dict(as_)}')
print(f'== REGRESSIONS={nreg} FIXED={nfix}')
