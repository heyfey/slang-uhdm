#!/usr/bin/env python3
# r10earl69 — rank the "GOLDEN holds a CONSTANT where WE hold a REF_OBJ"
# superfamily by (section, site kind, positional route tail, referenced name),
# from two cen67 censuses joined as a MULTISET (RESUME §9: keys collide, a
# last-writer dict drops rows).  MEASUREMENT ONLY.
#   usage: sfam67.py <golden.sx> <ours.sx> [GKIND] [OKIND]
import sys, re
from collections import defaultdict, Counter
GK = sys.argv[3] if len(sys.argv) > 3 else 'constant'
OK = sys.argv[4] if len(sys.argv) > 4 else 'ref_obj'
def load(p):
    d = defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split(' ')
        d[' '.join(f[:5])].append(f[5:])
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
pair = Counter(); fam = Counter(); names = defaultdict(Counter)
for k in set(g) | set(o):
    G, O = sorted(g.get(k, [])), sorted(o.get(k, []))
    n = max(len(G), len(O))
    G += [['<none>']] * (n - len(G)); O += [['<none>']] * (n - len(O))
    tag, sec, owner, site, path = k.split(' ')
    for i in range(n):
        gk, ok = G[i][0], O[i][0]
        pair[(gk, ok)] += 1
        if gk != GK or ok != OK:
            continue
        # positional route TAIL (the last route step) + the site's kind
        sk = site.split('_')[0]
        tail = path.split('/')[-1]
        tail = re.sub(r'\[\d+\]', '[]', tail)
        fam[(sec, sk, tail)] += 1
        nm = [x[5:] for x in O[i] if x.startswith('name=')]
        names[(sec, sk, tail)][nm[0] if nm else '-'] += 1
print('== KIND PAIRS (top 12) ==')
for (a, b), c in pair.most_common(12):
    print('%8d  G=%-20s O=%s' % (c, a, b))
print('== %s/%s SUPERFAMILY: %d cells ==' % (GK, OK, sum(fam.values())))
for (sec, sk, tail), c in fam.most_common(25):
    top = ' '.join('%s:%d' % (n, k) for n, k in names[(sec, sk, tail)].most_common(4))
    print('%8d  %-5s %-4s %-12s  %s' % (c, sec, sk, tail, top))
