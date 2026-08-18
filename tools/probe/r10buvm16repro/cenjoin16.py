#!/usr/bin/env python3
"""r10buvm16repro/cenjoin16.py -- MULTISET join of two `new`-call censuses.

LHS is ALWAYS golden.  Rows are keyed on everything the emitter is NOT changing
in this pass -- the test/mode tag, the call's file:line:col, the call name, the
call's own parent kind and the argument COUNT -- and the VALUE is the argument
list with every nested ref's Actual_group, which is exactly what this pass
moves.  A key that appears N times on one side and M on the other is reported
as ARITY so a shape change can never hide inside an AGREE.

`sub=`/`sk=`/`si=` are DELIBERATELY out of the key: our functions carry no
VpiFile, so the census's enclosing-routine lookup answers `?` on our side and
names the routine on golden's -- keying on it would make every row disagree for
a reason that has nothing to do with binding.

usage: cenjoin16.py <golden.census> <ours.census> [--only-dyn] [--loconly]
       --only-dyn keeps only the UNPARENTED calls, i.e. the dynamic-array
       `new[...]` form (Surelog parents the class-`new` form to the assignment).
       --loconly drops the FILE from the key and joins on line:col alone.

WHY --loconly EXISTS, and why it is the DEFAULT READING FOR A MOVER PREDICTION.
Our expression nodes carry an EMPTY VpiFile, so the census recovers the file
from a line-containment index -- and in a multi-file design that index answers
differently on the two sides (golden `uvm_factory.svh` vs ours
`uvm_reg_cbs.svh` for one and the same `new[m_packed_size]`).  Keyed with the
file, 270 REAL bind rows -- every dynamic-array `new` in MiniAmiq, Scoreboard,
SeqDriver and SimpleUVM -- fell into ARITY buckets and read as "no
disagreement".  THAT IS HOW A PREDICTION GOES WRONG: the first cut of this pass
predicted 2 mover databases from the file-keyed join and the loc-keyed join
found 9.  Line:col inside one test is unique enough (both sides put the
`new` at the same source position; that is what the census measures), so the
loc-only join is the sound one and the file stays a diagnostic.
"""
import sys
from collections import Counter, defaultdict


def load(path, only_dyn, loconly=False):
    keyed = defaultdict(Counter)
    for line in open(path):
        if not line.startswith('NEW '):
            continue
        f = line.rstrip('\n').split(' ')
        d = {}
        for tok in f[2:]:
            k, _, v = tok.partition('=')
            d[k] = v
        if only_dyn and d.get('par') != 'NONE':
            continue
        k = d.get('key') or ''
        if loconly:
            k = k.split('|')[-1]
        key = (f[1], k, d.get('nm'), d.get('par'), d.get('na'), d.get('sh'))
        keyed[key][d.get('a', '')] += 1
    return keyed


def main():
    only = '--only-dyn' in sys.argv[1:]
    loconly = '--loconly' in sys.argv[1:]
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    G, O = load(args[0], only, loconly), load(args[1], only, loconly)
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
