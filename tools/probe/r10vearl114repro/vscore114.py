#!/usr/bin/env python3
# r10vearl114 THREE-WAY SCORER -- MEASUREMENT ONLY.  The official uhdm-cmp is
# the sole acceptance judge.  LHS is ALWAYS golden.
#
# Reads the RAW vts114 rows for golden (G), pristine (P) and patched (Q) and
# scores every cell as a SHAPE-SET question, so arena copy COUNTS (which no
# generated Compare reads) cannot manufacture a verdict either way:
#
#   key   = (span-without-file, VpiName, the ancestor chain)   <- a READING key
#   value = the set of `ts=` payloads at that key on each side
#
#   SAME_AGREE  P==Q==G          (nothing moved, already right)
#   TOGOLD      P!=G and Q==G    (the law moved this cell ONTO golden)
#   AWAY        P==G and Q!=G    (**A REGRESSION**: pristine-right, patched-wrong)
#   MOVEDWRONG  P!=G, Q!=P, Q!=G (moved, but not onto golden)
#   STILLWRONG  P!=G, Q==P       (untouched divergence, pre-existing)
#   NOGOLD      the key does not exist in golden at all
#   NOOURS      the key exists only in golden
import sys, os, collections
COARSE = os.environ.get('COARSE') == '1'

def load(path, want):
    d = collections.defaultdict(set)
    n = 0
    for ln in open(path):
        ln = ln.rstrip('\n')
        if ln.startswith('VTS'): continue
        f = ln.split('\t')
        if len(f) < 10 or f[0] != want: continue
        span = f[1].split(':', 1)[1] if ':' in f[1] else f[1]
        key = (span, f[2]) if COARSE else (span, f[2], f[9])
        d[key].add(f[3])
        n += 1
    return d, n

def main(gold, pris, patch, tag):
    G, gn = load(gold, 'G'); P, pn = load(pris, 'P'); Q, qn = load(patch, 'Q')
    c = collections.Counter()
    lines = []
    for k in sorted(set(P) | set(Q) | set(G)):
        g, p, q = G.get(k), P.get(k), Q.get(k)
        if p is None and q is None:
            c['NOOURS'] += 1; continue
        if g is None:
            c['NOGOLD'] += 1
            if p != q: c['NOGOLD_MOVED'] += 1
            continue
        if p == g and q == g: c['SAME_AGREE'] += 1
        elif p != g and q == g:
            c['TOGOLD'] += 1
        elif p == g and q != g:
            c['AWAY'] += 1
            lines.append('[AWAY] %s|%s|%s\n   G %s\n   P %s\n   Q %s' % (tag, k[0], k[1], sorted(g), sorted(p), sorted(q)))
        elif q == p: c['STILLWRONG'] += 1
        else:
            c['MOVEDWRONG'] += 1
            lines.append('[MOVEDWRONG] %s|%s|%s\n   G %s\n   P %s\n   Q %s' % (tag, k[0], k[1], sorted(g), sorted(p), sorted(q)))
    print('ARM %s  rows G/P/Q %d/%d/%d' % (tag, gn, pn, qn))
    for l in lines: print(l)
    print('  ' + '  '.join('%s=%d' % (k, c[k]) for k in
          ('TOGOLD','AWAY','MOVEDWRONG','SAME_AGREE','STILLWRONG','NOGOLD','NOGOLD_MOVED','NOOURS')))
    return c

if __name__ == '__main__':
    tot = collections.Counter()
    for d in sys.argv[1:]:
        import os
        g, p, q = (os.path.join(d, x) for x in ('vts.gold.txt','vts.pris.txt','vts.patch.txt'))
        if not all(os.path.exists(x) for x in (g,p,q)):
            print('MISSING %s' % d); continue
        tot += main(g, p, q, os.path.basename(d.rstrip('/')))
    print('== TOTAL ' + '  '.join('%s=%d' % (k, tot[k]) for k in
          ('TOGOLD','AWAY','MOVEDWRONG','SAME_AGREE','STILLWRONG','NOGOLD','NOGOLD_MOVED','NOOURS')))
