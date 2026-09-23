#!/usr/bin/env python3
# predict111.py <cen-dir> <tag>: A-PRIORI mover prediction from golden vs PRISTINE census cells.
# A row is predicted to move under face F when a golden cell and our cell for the SAME key
# (param / ref / type-param fullname, or listing entry) differ in exactly the way the face's law
# rewrites:
#  F1  golden `logic_typespec(P::T) alias=-`  vs ours `logic_typespec(T) alias=P::T`
#      (or golden `(T) alias=-` vs ours `(T) alias=P::T`: the import-copy home)
#  F2  golden member alias target BARE parented at a ref_typespec vs ours `P::T`
#  F3  a listing cell present in ours' ALL listing and absent from golden's, or elem=none vs a name
#  F5  golden `actual=-` vs ours `actual=enum_const` for the same ref, or a golden ref ours lacks
#  F6  golden type_parameter bound to a non-packed_array typespec vs ours packed_array_typespec
import sys, os, collections, re
d, tag = sys.argv[1], sys.argv[2]
rows = sorted({fn.rsplit('.', 1)[0] for fn in os.listdir(d) if fn.endswith('.gold')})
def load(p):
    return [l.rstrip('\n') for l in open(p, errors='replace')] if os.path.exists(p) else None
pred = collections.defaultdict(set)
for r in rows:
    g, o = load(f'{d}/{r}.gold'), load(f'{d}/{r}.{tag}')
    if g is None or o is None: continue
    def by(lines, f, keyf):
        m = collections.defaultdict(list)
        for l in lines:
            if l.startswith(f):
                k, v = keyf(l); m[k].append(v)
        return m
    kf = lambda l: (l.split(' ')[1], ' '.join(l.split(' ')[2:]))
    G, O = by(g, 'F1', kf), by(o, 'F1', kf)
    for k in set(G) & set(O):
        for gv in G[k]:
            for ov in O[k]:
                mg = re.match(r'logic_typespec\((\S*)\) alias=(\S+)', gv); mo = re.match(r'logic_typespec\((\S*)\) alias=(\S+)', ov)
                if mg and mo and mg.group(2) == '-' and '::' in mo.group(2) and mo.group(1) != mg.group(1) or (mg and mo and mg.group(2) == '-' and '::' in mo.group(2) and '::' not in mg.group(1)):
                    pred['F1'].add(r)
    G, O = by(g, 'F2', kf), by(o, 'F2', kf)
    for k in set(G) & set(O):
        if any('alias=' in gv and '::' not in gv.split('alias=')[1].split()[0] and gv.endswith('ref_typespec') for gv in G[k]) and \
           any('::' in ov.split('alias=')[1].split()[0] for ov in O[k] if 'alias=' in ov):
            pred['F2'].add(r)
    gl = set(l for l in g if l.startswith('F3 ALL')); ol = set(l for l in o if l.startswith('F3 ALL'))
    gt = {' '.join(l.split()[:4]): l for l in g if l.startswith('F3')}; ot = {' '.join(l.split()[:4]): l for l in o if l.startswith('F3')}
    if any(' '.join(l.split()[:4]) not in gt for l in ol) or any(k in ot and 'elem=none' in ot[k] and 'elem=none' not in gt[k] for k in gt):
        pred['F3'].add(r)
    G, O = by(g, 'F5', kf), by(o, 'F5', kf)
    if any(k in O and 'actual=-' in G[k] and 'actual=enum_const' in O[k] for k in G) or any(k not in O for k in G):
        pred['F5'].add(r)
    G, O = by(g, 'F6', kf), by(o, 'F6', kf)
    if any(k in O and any(v.startswith('packed_array_typespec') for v in O[k]) and not any(v.startswith('packed_array_typespec') for v in G[k]) for k in G):
        pred['F6'].add(r)
for f in ('F1', 'F2', 'F3', 'F5', 'F6'):
    print(f, len(pred[f]), ' '.join(sorted(pred[f])))
