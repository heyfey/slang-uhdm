#!/usr/bin/env python3
"""r10buvm15repro/cenjoin15.py -- MULTISET join of two CALL censuses.

LHS is ALWAYS golden.  Rows are keyed on everything the emitter is NOT changing
in this pass -- the test/mode tag, the call's file:line:col, the call kind and
name, the collapsed flag and the enclosing subroutine's identity -- and the
VALUE is the argument list with its Actual_group kinds, which is exactly what
this pass moves.  A key that appears N times on one side and M on the other is
reported as ARITY so a shape change can never hide inside an AGREE.

usage: cenjoin15.py <golden.census> <ours.census> [--only-collapsed]
"""
import sys
from collections import Counter, defaultdict

def load(path, only_coll):
    keyed = defaultdict(Counter)
    for line in open(path):
        if not line.startswith('CALL '):
            continue
        f = line.rstrip('\n').split(' ')
        d = {}
        for tok in f[2:]:
            k, _, v = tok.partition('=')
            d[k] = v
        if only_coll and d.get('coll') != '1':
            continue
        key = (f[1], d.get('key'), d.get('ck'), d.get('nm'), d.get('coll'),
               d.get('sub'), d.get('sk'), d.get('sp'), d.get('si'),
               d.get('st'), d.get('na'))
        keyed[key][d.get('a', '')] += 1
    return keyed

def main():
    only = '--only-collapsed' in sys.argv[3:] or '--only-collapsed' in sys.argv[1:3]
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    G, O = load(args[0], only), load(args[1], only)
    agree = dis = miss = extra = arity = 0
    rows = []
    for k in sorted(set(G) | set(O)):
        g, o = G.get(k, Counter()), O.get(k, Counter())
        if sum(g.values()) != sum(o.values()):
            arity += 1
            rows.append(('ARITY', k, dict(g), dict(o)))
            continue
        if g == o:
            agree += sum(g.values())
            continue
        # same total count, different contents -> per-value multiset delta
        gonly, oonly = g - o, o - g
        dis += sum(gonly.values())
        agree += sum((g & o).values())
        rows.append(('DISAGREE', k, dict(gonly), dict(oonly)))
    for k in G:
        if k not in O:
            miss += 1
    for k in O:
        if k not in G:
            extra += 1
    for t, k, a, b in rows:
        print('%-9s %s' % (t, '|'.join(map(str, k))))
        print('    G: %s' % a)
        print('    O: %s' % b)
    print('TOTALS agree_rows=%d disagree_rows=%d arity_keys=%d '
          'golden_only_keys=%d ours_only_keys=%d' % (agree, dis, arity, miss, extra))

main()
