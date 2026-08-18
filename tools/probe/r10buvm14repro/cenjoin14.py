#!/usr/bin/env python3
"""r10buvm14 — the MULTISET JOIN over two r10buvm14cen outputs.

MEASUREMENT ONLY.  LHS is ALWAYS golden, RHS is ALWAYS ours, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.

  usage: cenjoin14.py <golden.cen> <ours.cen> [--only-mc] [--shapes N] [--sites]

Rows are keyed on `key=<view>|<file>|<line>:<col>` and the VALUE is the whole
remainder of the row (name/n/mc/nsel/args/shape).  Several hier_paths can share
one key, so the two sides' values are compared as MULTISETS and the classes are

  AGREE       the two multisets are equal
  DISAGREE    same key, same cardinality, different multiset
  ARITY-DIFF  same key, different cardinality
  MISSING/EXTRA   the key is on one side only

A CALIBRATION (golden against golden) must report DISAGREE 0 and ARITY-DIFF 0
before any golden-vs-ours number here means anything: a join that cannot report
zero on identical inputs cannot report N on different ones.
"""
import sys, collections

def load(path, only_mc):
    d = collections.defaultdict(list)
    n = 0
    for ln in open(path):
        if not ln.startswith('HP '):
            continue
        parts = ln.rstrip('\n').split(' ', 3)          # HP <tag> key=... rest
        key = parts[2][4:]
        rest = parts[3]
        if only_mc and ' mc=1 ' not in ' ' + rest + ' ':
            continue
        d[key].append(rest)
        n += 1
    for k in d:
        d[k].sort()
    return d, n

def main():
    a = sys.argv[1]; b = sys.argv[2]
    only_mc = '--only-mc' in sys.argv
    nshapes = 0
    if '--shapes' in sys.argv:
        nshapes = int(sys.argv[sys.argv.index('--shapes') + 1])
    G, ng = load(a, only_mc)
    O, no = load(b, only_mc)
    agree = dis = arity = miss = extra = 0
    exemplars = []
    for k in G:
        if k not in O:
            miss += 1
            continue
        g, o = G[k], O[k]
        if len(g) != len(o):
            arity += 1
        elif g == o:
            agree += 1
        else:
            dis += 1
            for x, y in zip(g, o):
                if x != y:
                    exemplars.append((k, x, y))
    for k in O:
        if k not in G:
            extra += 1
    print('rows: golden=%d ours=%d  keys: golden=%d ours=%d%s'
          % (ng, no, len(G), len(O), '  [mc=1 only]' if only_mc else ''))
    print('AGREE=%d DISAGREE=%d ARITY-DIFF=%d MISSING-OURS=%d EXTRA-OURS=%d'
          % (agree, dis, arity, miss, extra))
    if nshapes:
        fam = collections.Counter()
        for k, x, y in exemplars:
            gs = x.split(' shape=')[1] if ' shape=' in x else '?'
            os_ = y.split(' shape=')[1] if ' shape=' in y else '?'
            def norm(s):
                return '|'.join(p.split('(')[0] for p in s.split('|'))
            fam[(norm(gs), norm(os_))] += 1
        print('---- DISAGREE families (golden kinds -> our kinds), top %d' % nshapes)
        for (g, o), c in fam.most_common(nshapes):
            print('  %5d  G[%s]  ->  O[%s]' % (c, g, o))
    if '--sites' in sys.argv:
        print('---- DISAGREE sites')
        for k, x, y in exemplars:
            print('  KEY %s\n    G %s\n    O %s' % (k, x, y))

main()
