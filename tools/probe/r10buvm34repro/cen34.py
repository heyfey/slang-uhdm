#!/usr/bin/env python3
# r10buvm34repro/cen34.py — the SYMMETRIC MULTISET join of the FELV census.
#
# LHS is ALWAYS golden.  Both sides are enumerated by the SAME rule, so the
# join is symmetric and neither producer's vocabulary decides the key.
#
#   KEY     = (test, mode, HOME, foreach span, slot, loop-var NAME)
#   PAYLOAD = (loop-var KIND, loop-var ACTUAL TYPESPEC)
#
# The KIND and the TYPESPEC are what the two producers disagree about, so they
# are payload and never key (buvm33's rule: putting them in the key hides a
# disagreement as a MISSING/EXTRA pair).  The ARRAY reference's kind and name
# are payload too — buvm33 moved them, and a change there must not re-key this
# census.  Rows are joined as MULTISETS (a last-writer dict drops rows:
# buvm19/22's recorded trap).
#
#   cen34.py <cen.tsv> [--only-disagree] [--filter <substr>] [--by <field>]
import collections, sys
path = sys.argv[1]
args = sys.argv[2:]
filt = args[args.index('--filter') + 1] if '--filter' in args else None
by = args[args.index('--by') + 1] if '--by' in args else None
G = collections.defaultdict(collections.Counter)
O = collections.defaultdict(collections.Counter)
SPLIT = {}
for l in open(path):
    f = l.rstrip('\n').split('\t')
    if len(f) < 15 or f[1] != 'FELV':
        continue
    side, test, mode = f[0].split('|')
    if filt and filt not in l:
        continue
    key = (test, mode, f[2], f[3], f[4], f[5])
    val = (f[6], f[8])
    (G if side == 'G' else O)[key][val] += 1
    # the SPLIT columns are read off GOLDEN, so a cell is classified by the
    # side that is always right (RESUME §9: LHS is always golden)
    if side == 'G':
        SPLIT[key] = tuple(x.split('=', 1)[1] for x in (f[9], f[11], f[13], f[14]))  # akind, ascoped, arity, nskip
tot = collections.Counter()
bykey = collections.Counter()
for k in set(G) | set(O):
    g, o = G.get(k, collections.Counter()), O.get(k, collections.Counter())
    if not o:
        v = 'MISSING-OURS'
    elif not g:
        v = 'EXTRA-OURS'
    elif g == o:
        v = 'IDENTICAL'
    else:
        v = 'PAIRED-DISAGREE'
    tot[v] += 1
    sp = SPLIT.get(k, ('-', '-', '-', '-'))
    tot[('scoped', sp[1], v)] += 1
    if v != 'IDENTICAL' and by:
        bykey[tuple(sp) if by == 'split' else
              (sp[1], str(sorted(g.items())), str(sorted(o.items())))] += 1
    if v != 'IDENTICAL' and '--only-disagree' in args and not by:
        print(v, k, 'G:', dict(g), 'O:', dict(o), sp)
for v in ('IDENTICAL', 'PAIRED-DISAGREE', 'MISSING-OURS', 'EXTRA-OURS'):
    print(f"{v:16s} {tot[v]}")
for s in ('Y', 'N', '-'):
    row = " ".join(f"{v}={tot[('scoped', s, v)]}" for v in
                   ('IDENTICAL', 'PAIRED-DISAGREE', 'MISSING-OURS', 'EXTRA-OURS'))
    print(f"  ascoped={s}: {row}")
for k, n in bykey.most_common(60):
    print(f"  {n:6d}  {k}")
