#!/usr/bin/env python3
"""r10uvm177 — the golden-vs-ours JOIN over the return-variable census.

MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

The join is a MULTISET join (RESUME 9: keys collide; a last-writer dict drops
rows), keyed on (LISTING, HOME, FN, RVPOS) -- the source position of the return
variable inside a named listing.  The SPAN of the typespec is deliberately kept
OUT of the key and out of the verdict by default (`uhdm-cmp` reads no span);
pass --span to fold it in.

usage: join177.py <gold.tsv> <ours.tsv> <tag> [--span] [--list KIND]
"""
import sys
from collections import Counter, defaultdict


def load(p):
    rows = []
    with open(p) as f:
        for ln in f:
            if ln.startswith('#'):
                continue
            c = ln.rstrip('\n').split('\t')
            if len(c) < 9:
                continue
            rows.append(c)
    return rows


def main():
    gp, op, tag = sys.argv[1], sys.argv[2], sys.argv[3]
    use_span = '--span' in sys.argv
    want = None
    if '--list' in sys.argv:
        want = sys.argv[sys.argv.index('--list') + 1]

    def key(c):
        return (c[0], c[1], c[2], c[3])

    def val(c):
        return (c[4], c[6], c[7]) + ((c[8],) if use_span else ())

    G = defaultdict(list)
    O = defaultdict(list)
    for c in load(gp):
        G[key(c)].append(val(c))
    for c in load(op):
        O[key(c)].append(val(c))

    agree = 0
    diff = Counter()
    gonly = Counter()
    oonly = Counter()
    listed = []
    for k in set(G) | set(O):
        gm = Counter(G.get(k, []))
        om = Counter(O.get(k, []))
        common = gm & om
        agree += sum(common.values())
        gl = list((gm - common).elements())
        ol = list((om - common).elements())
        n = min(len(gl), len(ol))
        for i in range(n):
            d = (gl[i], ol[i])
            diff[d] += 1
            listed.append((k, gl[i], ol[i]))
        for x in gl[n:]:
            gonly[x] += 1
            listed.append((k, x, None))
        for x in ol[n:]:
            oonly[x] += 1
            listed.append((k, None, x))

    print(f'== {tag} (span_in_key={use_span})')
    print(f'   AGREE   {agree}')
    print(f'   DIFF    {sum(diff.values())}')
    print(f'   G-ONLY  {sum(gonly.values())}')
    print(f'   O-ONLY  {sum(oonly.values())}')
    for (g, o), n in diff.most_common():
        print(f'   DIFF {n:5d}  G={g}   O={o}')
    for x, n in gonly.most_common(20):
        print(f'   G-ONLY {n:5d}  {x}')
    for x, n in oonly.most_common(20):
        print(f'   O-ONLY {n:5d}  {x}')
    if want:
        for k, g, o in sorted(listed, key=lambda t: str(t)):
            if want == 'all' or (g and want in str(g)) or (o and want in str(o)):
                print(f'   CELL {k}  G={g}  O={o}')


main()
