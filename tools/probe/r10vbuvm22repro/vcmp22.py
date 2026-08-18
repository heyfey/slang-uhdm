#!/usr/bin/env python3
"""r10vbuvm22 — VIEW-GENERAL three-way return-variable comparator.

MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

Reads the TSV r10buvm22cen emits (tag \t SITE \t VIEW \t fullname \t floc \t
home \t parkind \t quals \t KIND \t vloc \t tsShape \t tsname \t sgn) for six
tags -- GD/GE (golden def/elab), PD/PE (pristine), QD/QE (patched) -- and
scores every (view, fullname, site, vloc) SLOT as a MULTISET, so colliding keys
are never silently dropped by a last-writer dict.

payload  = (KIND, tsShape, tsname)     -- var kind + typespec shape
verdicts = CONVERTED / MSW-REGRESSION / same / still-wrong / moved-still-wrong
           and, separately, the same scoring for the KIND alone.
"""
import collections, sys

path = sys.argv[1]
kindonly = '--kindonly' in sys.argv
rows = collections.defaultdict(lambda: collections.defaultdict(list))
for line in open(path):
    f = line.rstrip('\n').split('\t')
    if len(f) < 13:
        continue
    tag, site, view, fn, floc, home, par, quals, kind, vloc, tsshape, tsname, sgn = f[:13]
    key = (view, fn, site, vloc)
    payload = kind if kindonly else (kind, tsshape, tsname)
    rows[key][tag].append(payload)

def ms(x):
    return tuple(sorted(x))

conv = msw = same = wrong = 0
out = []
missing = collections.Counter()
for key in sorted(rows):
    c = rows[key]
    for g, p, q, vw in (('GD', 'PD', 'QD', 'D'), ('GE', 'PE', 'QE', 'E')):
        if not (g in c and p in c and q in c):
            if g in c or p in c or q in c:
                missing[(vw, tuple(sorted(t for t in (g, p, q) if t not in c)))] += 1
            continue
        gk, pk, qk = ms(c[g]), ms(c[p]), ms(c[q])
        if pk != gk and qk == gk:
            v = 'CONVERTED'; conv += 1
        elif pk == gk and qk != gk:
            v = 'MSW-REGRESSION'; msw += 1
        elif pk == gk and qk == gk:
            v = 'same'; same += 1
        elif pk == qk:
            v = 'still-wrong'; wrong += 1
        else:
            v = 'moved-still-wrong'; wrong += 1
        if v != 'same':
            out.append((key, vw, gk, pk, qk, v))

for key, vw, gk, pk, qk, v in out:
    print(f"{v:18} {key[0]:9}/{vw} {key[1]:60} @{key[3]:10} G={gk} P={pk} Q={qk}")
print()
for k, n in sorted(missing.items()):
    print(f"MISSING-SIDE {k[0]} absent={','.join(k[1])} slots={n}")
print('CONVERTED %d  MSW-REGRESSION %d  still-wrong %d  same %d  scored %d'
      % (conv, msw, wrong, same, conv + msw + wrong + same))
