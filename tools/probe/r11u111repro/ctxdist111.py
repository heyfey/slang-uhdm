#!/usr/bin/env python3
# ctxdist111.py <gold.dump> <A.dump> <B.dump>: CONTEXT-KEYED whole-dump distance.  Every uhdm-dump
# line is keyed by the chain of object headers (`\_kind: (name)` lines, ids stripped) that own it,
# so a generic field line (`|vpiParent:`, `|UINT:0`) counts against the OBJECT it belongs to, not
# against an order-blind pool where an extra body in one place cancels a missing body elsewhere.
# Spans (file/line/col), vpiParent fields and vpiFullName (incl. a ref_typespec header's name) are
# stripped -- no generated Compare reads any of them --
# and the weaklyReferenced tail is not counted (unreachable to the judge).
# Prints dist(gold,A) dist(gold,B) and the OBJECTS (owning header chains) whose own distance to
# golden grows from A to B (AWAY).
import sys, re, collections
def load(p):
    c = collections.Counter(); st = []; skip = False
    for i, ln in enumerate(open(p, errors='replace')):
        if i == 0: continue
        # vpiParent is never Compare-read: drop the field and the header it names
        if skip:
            skip = False; continue
        if ln.strip() == '|vpiParent:':
            skip = True; continue
        # the weaklyReferenced TAIL is unreachable to the judge (RESUME 8): stop there
        if ln.startswith('\\_weaklyReferenced'):
            break
        ln = re.sub(r', id:\d+', '', ln.rstrip('\n'))
        # spans are never Compare-read: drop them everywhere (headers AND reference lines)
        ln = re.sub(r', (file:[^,]*, )?line:\d+:\d+, endln:\d+:\d+', '', ln)
        # nor a vpiFullName (a ref_typespec header prints its fullname: blank it)
        if ln.strip().startswith('|vpiFullName:'):
            continue
        ln = re.sub(r'\\_ref_typespec: \(.*\)$', r'\\_ref_typespec:', ln)
        ind = len(ln) - len(ln.lstrip(' '))
        body = ln.strip()
        while st and st[-1][0] >= ind: st.pop()
        key = '/'.join(h for _, h in st)
        c[key + ' || ' + body] += 1
        if body.startswith('\\_'): st.append((ind, body))
    return c
g, a, b = (load(p) for p in sys.argv[1:4])
def dist(x, y): return sum(((x - y) + (y - x)).values())
print('ctxdist', dist(g, a), dist(g, b))
# PER-OBJECT (per owning header chain) scoring: an object is AWAY when its own line-multiset
# distance to golden GROWS from A to B (a changed but equally-wrong object is LATERAL).
def objs(c):
    o = collections.defaultdict(collections.Counter)
    for k, v in c.items():
        path, body = k.split(' || ', 1)
        o[path][body] += v
    return o
G, A, B = objs(g), objs(a), objs(b)
away = []
for path in set(A) | set(B):
    da, db = dist(G.get(path, collections.Counter()), A.get(path, collections.Counter())), \
             dist(G.get(path, collections.Counter()), B.get(path, collections.Counter()))
    if db > da: away.append((path, da, db))
for path, da, db in sorted(away)[:int(sys.argv[4]) if len(sys.argv) > 4 else 40]:
    print('AWAY-OBJ', f'{da}->{db}', path)
print('AWAY-KEYS', len(away))
