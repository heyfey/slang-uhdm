#!/usr/bin/env python3
# r10buvm21repro/cen3.py — THE THREE-WAY JOIN (golden / pristine / patched) over
# r10buvm21cen rows.  MEASUREMENT ONLY.  LHS is ALWAYS golden.
#
# MULTISET join (keys collide — two references to the same name at the same
# shape in one subroutine are two rows, and a last-writer dict would drop one).
# The KEY is (view, owner subroutine fullname, node kind, name[@loc], shape);
# pass --noloc to drop the location from the key, which is what the grid arms
# need because our `bit_select` spans the INDEX where golden spans the whole
# select — a span, and no span, is a field `Compare` never reads.
#
# usage: cen3.py <g.tsv> <o.tsv> [p.tsv] [--noloc] [--quiet]
import sys, collections

args = [a for a in sys.argv[1:] if not a.startswith('--')]
flags = {a for a in sys.argv[1:] if a.startswith('--')}
noloc = '--noloc' in flags
quiet = '--quiet' in flags

def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        nm = f[7].split('@')[0] if noloc else f[7]
        d[(f[1], f[2], f[6], nm, f[8])].append(f[11])
    return {k: sorted(v) for k, v in d.items()}

G = load(args[0]); O = load(args[1])
P = load(args[2]) if len(args) > 2 else None
ks = sorted(set(G) | set(O) | (set(P) if P is not None else set()))
n = same = conv = over = res = msw = 0
for k in ks:
    g, o = G.get(k), O.get(k)
    p = P.get(k) if P is not None else None
    n += 1
    if P is None:
        v = 'same' if g == o else 'DIFF'
        if v == 'same':
            same += 1
    elif g == o == p:
        v = 'same'; same += 1
    elif g != o and g == p:
        v = 'CONVERTED'; conv += 1
    elif g == o and g != p:
        v = 'OVER-FIRE'; over += 1
    elif g != o and o == p:
        v = 'residue'; res += 1
    else:
        v = 'MOVED-STILL-WRONG'; msw += 1
    if v == 'same':
        continue
    if quiet and v == 'residue':
        continue
    print('%-18s %s\n    G=%s\n    O=%s\n    P=%s' % (v, k, g, o, p))
print('-- CELLS %d  same %d  CONVERTED %d  OVER-FIRE %d  MOVED-STILL-WRONG %d  residue %d'
      % (n, same, conv, over, msw, res))
