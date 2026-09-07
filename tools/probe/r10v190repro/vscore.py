#!/usr/bin/env python3
# r10v190 verifier scorer.  MEASUREMENT ONLY.
# Joins golden / pristine / patched census rows as a MULTISET per key
# (view + section + typespec kind + name + span + alias + alias span) and
# scores each key's payload multiset:
#   TO-GOLDEN  : a payload count that moved toward golden's
#   AWAY       : moved away  <-- any nonzero here is a REGRESSION
#   STILL-WRONG: changed but still not golden
#   WRONG-KEPT : wrong before and after (not this pass's business)
# The DEF/ELAB view stays IN the key (the two views are different designs), but
# the two producers' listings are never merged across sections.
import sys, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    for line in open(p):
        line = line.rstrip('\n')
        if not line: continue
        f = line.split('\t')
        if len(f) < 8: continue
        key = ' | '.join(f[0:7])
        d[key][f[7]] += 1
    return d

g, a, b = load(sys.argv[1]), load(sys.argv[2]), load(sys.argv[3])
sect = sys.argv[4] if len(sys.argv) > 4 else None

def keep(k):
    return sect is None or (' | ' + sect + ' | ') in (' | ' + k.split(' | ',2)[1] + ' | ')

keys = sorted(set(list(g)+list(a)+list(b)))
tot = dict(gc=0, ac=0, bc=0, am=0, bm=0, to=0, aw=0, sw=0, wk=0, rk=0, mv=0)
moved = []
for k in keys:
    if sect and k.split(' | ')[1] != sect: continue
    G, A, B = g.get(k, collections.Counter()), a.get(k, collections.Counter()), b.get(k, collections.Counter())
    tot['gc'] += sum(G.values()); tot['ac'] += sum(A.values()); tot['bc'] += sum(B.values())
    tot['am'] += sum(min(A[p], G[p]) for p in A)
    tot['bm'] += sum(min(B[p], G[p]) for p in B)
    if A == B:
        # unchanged key: right-kept vs wrong-kept, per payload
        for p in A:
            m = min(A[p], G[p]); tot['rk'] += m; tot['wk'] += A[p]-m
        continue
    tot['mv'] += 1
    ma = sum(min(A[p], G[p]) for p in A)
    mb = sum(min(B[p], G[p]) for p in B)
    d = mb - ma
    if d > 0: tot['to'] += d
    elif d < 0: tot['aw'] += -d
    changed = sum((A-B).values()) + sum((B-A).values())
    tot['sw'] += max(0, changed//2 - abs(d))
    moved.append((k, G, A, B, ma, mb))

print(f"section={sect}  golden cells {tot['gc']}  ours pristine {tot['ac']} patched {tot['bc']}")
print(f"  matching golden   pristine {tot['am']}   patched {tot['bm']}")
print(f"  TO-GOLDEN {tot['to']}   AWAY-GOLDEN {tot['aw']}   CHANGED-STILL-WRONG {tot['sw']}")
print(f"  RIGHT-KEPT {tot['rk']}   WRONG-KEPT {tot['wk']}   moved keys {tot['mv']}")
for k, G, A, B, ma, mb in moved:
    flag = "AWAY!!" if mb < ma else ("TO-GOLDEN" if mb > ma else "SIDEWAYS")
    print(f"  [{flag}] KEY {k}")
    for tagname, C in (("golden", G), ("pristine", A), ("patched", B)):
        for p, n in sorted(C.items()):
            print(f"     {tagname:9s} x{n}  {p}")
    print(f"     match pristine={ma} patched={mb}")
