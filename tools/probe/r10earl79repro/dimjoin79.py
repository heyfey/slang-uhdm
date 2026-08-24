#!/usr/bin/env python3
# r10earl79 — join a GOLDEN and an OURS `dimscan79` listing and split the
# size-form unpacked dimension bounds into the TWO DISJOINT POPULATIONS this
# pass must keep apart:
#   EXPR  the written size is an EXPRESSION — golden's fold is re-spanned at
#         the expression's FIRST CHILD, so golden's span is a STRICT PREFIX of
#         ours (same start, earlier end).  § dimExprBoundFold79's population.
#   NAME  the written size is a bare name or a literal — both sides span the
#         same token.  § dimBoundInheritsParamEnc74's population.
# The key is (owner kind, owner name, start line, start col) — a MULTISET, so
# the N instances of one declaration are N cells.  No span is scored: the
# judge fields are ct / sz / val / dec.
#   usage: dimjoin79.py <golden.dim> <ours.dim> [--cells]
import sys, collections, re
LINE = re.compile(r'^DIM (\S+) (\S+) ct=(-?\d+) sz=(-?\d+) val=(\S+) dec=(\S+) @(\S+):(\d+):(\d+)-(\d+):(\d+)$')
def load(p):
    d = collections.defaultdict(list)
    for l in open(p):
        m = LINE.match(l.rstrip('\n'))
        if not m: continue
        kind, name, ct, sz, val, dec, f, l0, c0, l1, c1 = m.groups()
        d[(kind, name, int(l0), int(c0))].append(
            (int(ct), int(sz), val, dec, int(l1), int(c1)))
    return d
g, o = load(sys.argv[1]), load(sys.argv[2])
cells = '--cells' in sys.argv
tal = collections.Counter()
for k in sorted(set(g) & set(o)):
    G, O = sorted(g[k]), sorted(o[k])
    n = min(len(G), len(O))
    for i in range(n):
        gg, oo = G[i], O[i]
        expr = (gg[4], gg[5]) < (oo[4], oo[5])
        pop = 'EXPR' if expr else 'NAME'
        agree = gg[:4] == oo[:4]
        tal[pop] += 1
        tal[pop + ('_AGREE' if agree else '_DIFFER')] += 1
        if not agree:
            tal[pop + '_SZ'] += (gg[1] != oo[1])
            tal[pop + '_CT'] += (gg[0] != oo[0])
            tal[pop + '_VAL'] += (gg[2] != oo[2])
            tal[pop + '_DEC'] += (gg[3] != oo[3])
        if cells and not agree:
            print("CELL %s %s %s @%d:%d G%s O%s" % (pop, k[0], k[1], k[2], k[3], gg[:4], oo[:4]))
    tal['UNMATCHED'] += abs(len(G) - len(O))
tal['GOLDEN_ONLY_KEYS'] = len(set(g) - set(o))
tal['OURS_ONLY_KEYS'] = len(set(o) - set(g))
for k in sorted(tal):
    print("%-18s %d" % (k, tal[k]))
