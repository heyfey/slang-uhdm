#!/usr/bin/env python3
"""v91 verifier: depth-keyed CELL census.
For every type_parameter and every class TYPEDEF-listing typespec in a dump,
emit  (owner_class, SITE, kind, NAME)  keyed by DEPTH+PATH, not by line number.
Span is deliberately NOT part of the key (dump-only per the measurement laws).
"""
import re, sys, collections

LINE = re.compile(r'^(\s*)\\_(\w+): \(([^)]*)\)(.*)$')

def parse(path):
    nodes = []           # (depth, kind, name, rest)
    for ln in open(path, errors='replace'):
        m = LINE.match(ln.rstrip('\n'))
        if not m: continue
        ind, kind, name, rest = m.groups()
        nodes.append((len(ind), kind, name, rest))
    return nodes

def cells(path):
    nodes = parse(path)
    out = {}
    stack = []  # (depth, kind, name)
    for i,(d,k,n,rest) in enumerate(nodes):
        while stack and stack[-1][0] >= d: stack.pop()
        stack.append((d,k,n))
        if k == 'type_parameter':
            # find the ref_typespec child, then its typespec child
            j = i+1; ts = None
            while j < len(nodes) and nodes[j][0] > d:
                if nodes[j][1] == 'ref_typespec' and nodes[j][0] == d+2:
                    kk = j+1
                    while kk < len(nodes) and nodes[kk][0] > nodes[j][0]:
                        if nodes[kk][1].endswith('typespec') and nodes[kk][1] != 'ref_typespec':
                            ts = (nodes[kk][1], nodes[kk][2]); break
                        kk += 1
                    if ts: break
                j += 1
            out.setdefault(('TYPEPARAM', n), []).append(ts)
    return out

def load(p):
    c = cells(p)
    return {k: tuple(v) for k,v in c.items()}

g, a, b = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
keys = sorted(set(g)|set(a)|set(b))
nrg=nrb=fixed=broke=both=0
for k in keys:
    gv, av, bv = g.get(k), a.get(k), b.get(k)
    okA, okB = (gv==av), (gv==bv)
    if okA and okB: continue
    if okA and not okB:
        broke += 1; tag='*** PRISTINE-RIGHT -> PATCHED-WRONG ***'
    elif not okA and okB:
        fixed += 1; tag='fixed'
    else:
        both += 1
        if av==bv: continue          # unchanged, still wrong -- residue
        tag='changed-still-wrong'
    print(f'{tag}  {k[1]}\n    golden={gv}\n    pris  ={av}\n    pat   ={bv}')
print(f'---- CELLS golden={len(g)} pris={len(a)} pat={len(b)}  FIXED={fixed}  BROKEN={broke}  changed-still-wrong={both}')
