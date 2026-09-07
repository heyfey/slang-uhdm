#!/usr/bin/env python3
# r10vearl114 EXHAUSTIVE AWAY HUNT -- MEASUREMENT ONLY.
# The one question that decides the verdict, asked without a join key that can
# hide a cell: is there ANY hier_path in ANY of our databases that carries a
# typespec edge which NO golden hier_path at the same (span, name) carries?
# That is the ONLY shape in which this patch can be wrong: hanging where golden
# does not, or hanging something golden never hangs.
import sys, os, collections
def load(p, w):
    d = collections.defaultdict(set)
    for ln in open(p):
        if ln.startswith('VTS'): continue
        f = ln.rstrip('\n').split('\t')
        if len(f) < 10 or f[0] != w: continue
        span = f[1].split(':', 1)[1] if ':' in f[1] else f[1]
        d[(span, f[2])].add(f[3])
    return d
bad = pris_bad = tot = 0
for dd in sys.argv[1:]:
    g = load(os.path.join(dd, 'vts.gold.txt'), 'G')
    p = load(os.path.join(dd, 'vts.pris.txt'), 'P')
    q = load(os.path.join(dd, 'vts.patch.txt'), 'Q')
    for k, vs in q.items():
        for v in vs:
            if v == 'ts=<none>': continue
            tot += 1
            if v not in g.get(k, set()):
                bad += 1
                print('UNJUSTIFIED-HANG %s %s %s -> %s   (golden holds %s)' %
                      (os.path.basename(dd.rstrip('/')), k[0], k[1], v, sorted(g.get(k, set()))))
    for k, vs in p.items():
        for v in vs:
            if v != 'ts=<none>' and v not in g.get(k, set()): pris_bad += 1
print('== hung payload instances in OURS: %d ; NOT held by golden at the same span+name: %d '
      '(the same count on the PRISTINE binary: %d)' % (tot, bad, pris_bad))
