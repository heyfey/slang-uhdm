#!/usr/bin/env python3
"""r10vbuvm22 — OWNER-KEYED three-way corpus census with a Compare-visible
payload.  MEASUREMENT ONLY.  LHS is ALWAYS golden.

key     = (VIEW, function fullname, SITE, return-var line:col)  as a MULTISET
payload = (object kind, typespec shape, typespec name)  -- exactly the fields
          BaseClass::Compare / variables::Compare read for this object.
verdict per slot: TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG / STILL-RIGHT.
   vcen3.py <golden.tsv> <pristine.tsv> <patched.tsv> [--kindonly]
"""
import collections, sys
kindonly = '--kindonly' in sys.argv
args = [a for a in sys.argv[1:] if not a.startswith('--')]

def load(p):
    d = collections.defaultdict(list)
    for line in open(p):
        f = line.rstrip('\n').split('\t')
        if len(f) < 13:
            continue
        _, site, view, fn, floc, home, par, quals, kind, vloc, tss, tsn, sgn = f[:13]
        d[(view, fn, site, vloc)].append(kind if kindonly else (kind, tss, tsn))
    return d

G, P, Q = (load(a) for a in args[:3])
keys = set(G) | set(P) | set(Q)
tog = away = stillw = stillr = onlyg = onlyo = 0
rows = []
for k in sorted(keys):
    g, p, q = tuple(sorted(G.get(k, []))), tuple(sorted(P.get(k, []))), tuple(sorted(Q.get(k, [])))
    if not g:
        onlyo += 1
        if p != q: rows.append(('EXTRA-OURS-MOVED', k, g, p, q))
        continue
    if not p and not q:
        onlyg += 1
        continue
    if p == g and q == g: stillr += 1; continue
    if p != g and q == g: tog += 1; rows.append(('TO-GOLDEN', k, g, p, q)); continue
    if p == g and q != g: away += 1; rows.append(('AWAY-GOLDEN', k, g, p, q)); continue
    stillw += 1
    if p != q: rows.append(('STILL-WRONG-MOVED', k, g, p, q))
for v, k, g, p, q in rows:
    print(f"{v:18} {k[0]:9} {k[2]:8} {k[1][:70]:70} @{k[3]:12} G={g} P={p} Q={q}")
print(f"TO-GOLDEN {tog}  AWAY-GOLDEN {away}  STILL-WRONG {stillw}  STILL-RIGHT {stillr}  "
      f"GOLDEN-ONLY-SLOTS {onlyg}  OURS-ONLY-SLOTS {onlyo}")
