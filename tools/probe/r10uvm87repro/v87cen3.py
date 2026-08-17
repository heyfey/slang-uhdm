#!/usr/bin/env python3
import re, sys, collections
OBJ = re.compile(r'^(\s*)\\_([a-zA-Z_]+): (\(([^)]*)\))?')
def census(path):
    out = collections.defaultdict(collections.Counter); stack=[]
    for line in open(path, errors='replace'):
        m = OBJ.match(line.rstrip('\n'))
        if not m: continue
        ind=len(m.group(1)); kind=m.group(2); nm=m.group(4) or ''
        while stack and stack[-1][0] >= ind: stack.pop()
        if kind=='class_typespec':
            out['/'.join(x[1] for x in stack[-3:])][nm]+=1
        stack.append((ind,f'{kind}({nm})'))
    return out
g,p,a = (census(f) for f in sys.argv[1:4])
reg=fix=0
for k in sorted(set(g)|set(p)|set(a)):
    gs,ps,as_ = g.get(k,collections.Counter()),p.get(k,collections.Counter()),a.get(k,collections.Counter())
    if ps==as_ or not gs: continue
    if ps==gs and as_!=gs: reg+=1; print(f'REGRESSION {k}\n   G={dict(gs)}\n   P={dict(ps)}\n   A={dict(as_)}')
    elif ps!=gs and as_==gs: fix+=1
    elif as_!=gs: print(f'STILL-WRONG {k}\n   G={dict(gs)}\n   P={dict(ps)}\n   A={dict(as_)}')
print(f'== REGRESSIONS={reg} FIXED={fix}  ({sys.argv[0]})')
