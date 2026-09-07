#!/usr/bin/env python3
"""r10earl116 — the ASSIGNMENT-PATTERN FLATTENED-NESS scorer.  MEASUREMENT ONLY.

Joins the golden and ours `sig116` censuses as a MULTISET and scores the SHAPE
(the set of payloads seen at a key) exactly the way r10earl115's sig115.py does:

   TOGOLD / AWAY / MOVEDWRONG / SAME_AGREE / STILLWRONG / NOGOLD / GOLDENONLY

TWO FAMILIES, because the reading key and the scoring key must not be the same
key (r10earl114's precedent):

  FX  span + Lhs name + Lhs KIND + Lhs ACTUAL kind + scope + gen depth + carrier
      — the law's own surface: the flatten gate `cont_assign::DeepClone` applies
      is exactly (Lhs kind, Lhs actual kind).
  F0  span + Lhs name ALONE — the COARSE key, which is what catches a cell whose
      Lhs OBJECT KIND differs between the two emitters (our `wire`-declared
      struct is a `logic_net` where golden's is a `struct_var`) and would
      otherwise hide as NOGOLD in FX.

The VIEW (plain / elab) is deliberately NOT in either key: the two producers
label the DEF and ELAB copies differently (RESUME.md §9).  The caller compares
one arm/view directory at a time, so the view is constant within a comparison.

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
usage: sig116.py <gold.txt> <pris.txt> [patch.txt] [-v]
"""
import sys
import collections


def load(path, fam):
    d = collections.defaultdict(collections.Counter)
    for line in open(path):
        if not line.startswith('R|'):
            continue
        f = line.rstrip('\n').split('|')
        # 0=R 1=LABEL 2=SPAN 3=LNAME 4=LK 5=LACT 6=SC 7=GD 8=CAR
        # 9=NOPS 10=TAG 11=FLAT 12=OPK
        if len(f) < 13:
            continue
        key = (f[2], f[3])
        if fam == 'FX':
            key = key + (f[4], f[5], f[6], f[7], f[8])
        d[key][f[11] + ':' + f[12]] += 1
    return d


def score(g, p, q):
    res = collections.Counter()
    rows = []
    for k in sorted(set(g) | set(p) | set(q)):
        G, P, Q = set(g.get(k, {})), set(p.get(k, {})), set(q.get(k, {}))
        if not G:
            res['NOGOLD'] += 1
            if P != Q:
                res['NOGOLD_MOVED'] += 1
                rows.append(('NOGOLD_MOVED', k, G, P, Q))
            continue
        if not P and not Q:
            res['GOLDENONLY'] += 1
            continue
        if P == Q:
            if P == G:
                res['SAME_AGREE'] += 1
            else:
                res['STILLWRONG'] += 1
                rows.append(('STILLWRONG', k, G, P, Q))
            continue
        if P != G and Q == G:
            res['TOGOLD'] += 1
            rows.append(('TOGOLD', k, G, P, Q))
        elif P == G and Q != G:
            res['AWAY'] += 1
            rows.append(('AWAY', k, G, P, Q))
        else:
            res['MOVEDWRONG'] += 1
            rows.append(('MOVEDWRONG', k, G, P, Q))
    return res, rows


if __name__ == '__main__':
    verbose = '-v' in sys.argv
    args = [a for a in sys.argv[1:] if a != '-v']
    for fam in ('FX', 'F0'):
        g = load(args[0], fam)
        p = load(args[1], fam)
        q = load(args[2], fam) if len(args) > 2 else p
        res, rows = score(g, p, q)
        if verbose:
            for t, k, G, P, Q in rows:
                print("[%s %s] %s" % (fam, t, ' | '.join(map(str, k))))
                print("     G:%s  P:%s  Q:%s" % (G, P, Q))
        print("-- %s " % fam + "  ".join("%s=%d" % (k, v)
                                         for k, v in sorted(res.items())))
