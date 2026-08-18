#!/usr/bin/env python3
"""r10buvm23repro/gridcmp23.py — THE THREE-WAY GRID SCORER.

MEASUREMENT ONLY.  LHS is ALWAYS golden.

Scores every hier_path cell of a grid three ways — golden, pristine, patched —
as a MULTISET over (view+tag, owner, loc) so a cell listed twice cannot be
dropped by a last-writer dict (RESUME §9 census traps), and so a change in
MULTIPLICITY is itself visible.

Payload is the JUDGE-VISIBLE part only by default (VpiName, Path_elems size,
per-element kind+VpiName+index kind); `--full` adds VpiFullName, which no
generated `Compare` reads.

  FIXED          pristine != golden, patched == golden
  BROKEN         pristine == golden, patched != golden     <- must be 0
  STILL-WRONG    both differ from golden
  STILL-RIGHT    both equal golden

  usage: gridcmp23.py <cen.g.txt> <cen.pris.txt> <cen.pat.txt> [--full] [--list]
"""
import sys, collections

FULL = '--full' in sys.argv
LIST = '--list' in sys.argv

def cmpvis(elems):
    out = []
    for e in elems.split(' | '):
        f = e.split(':')
        out.append(':'.join(f[:2] + [x for x in f[3:] if x.startswith('idx=')]))
    return ' | '.join(out)

def load(path):
    d = collections.defaultdict(collections.Counter)
    for ln in open(path):
        f = ln.rstrip('\n').split('\t')
        if len(f) < 9 or f[1] != 'HP':
            continue
        key = (f[0].split('.')[-1], f[2], f[3], f[4])   # listing(def/elab), view, owner, loc
        el = f[8] if FULL else cmpvis(f[8])
        d[key][(f[5], f[6], el)] += 1
    return d

g, pr, pa = (load(p) for p in sys.argv[1:4])
keys = sorted(set(g) | set(pr) | set(pa))
score = collections.Counter()
rows = []
for k in keys:
    gg, pp, qq = g.get(k, collections.Counter()), pr.get(k, collections.Counter()), pa.get(k, collections.Counter())
    okp, okq = (pp == gg), (qq == gg)
    if okp and okq:      v = 'STILL-RIGHT'
    elif not okp and okq: v = 'FIXED'
    elif okp and not okq: v = 'BROKEN'
    else:                 v = 'STILL-WRONG'
    score[v] += 1
    if v != 'STILL-RIGHT' or LIST:
        rows.append((v, k, gg, pp, qq))
print('CELLS %d   FIXED %d  BROKEN %d  STILL-WRONG %d  STILL-RIGHT %d' %
      (len(keys), score['FIXED'], score['BROKEN'], score['STILL-WRONG'], score['STILL-RIGHT']))
for v, k, gg, pp, qq in rows:
    print('--- %-12s %s' % (v, ' | '.join(k)))
    def show(t, c):
        for p, n in sorted(c.items()):
            print('    %s x%d name=%s %s' % (t, n, p[0], p[1]))
            print('        %s' % p[2])
    show('G', gg); show('P', pp); show('Q', qq)
