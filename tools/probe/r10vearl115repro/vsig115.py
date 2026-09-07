#!/usr/bin/env python3
"""r10vearl115 -- the INSTANCE-KEYED, MULTISET element scorer.  MEASUREMENT ONLY.

r10earl115's `sig115.py` collapses every instance's copy of a cell into one key
and compares payload SETS, so (a) it cannot say WHICH instance moved and (b) a
change in the NUMBER of bound copies is invisible to it.  This scorer keys on
the instance path as well and compares Counters, so a copy-count change scores.

  VX  instance path + span + name + idx/pos/kind + carrier   (the sharp key)
  V0  span + name + idx/pos/kind                             (the coarse key)

LHS is ALWAYS golden; RHS is ALWAYS ours.
usage: vsig115.py <gold.txt> <pris.txt> [patch.txt] [-v]
"""
import sys, collections

def load(p, fam):
    d = collections.defaultdict(collections.Counter)
    for line in open(p):
        if not line.startswith('VROW'):
            continue
        f = line.rstrip('\n').split('\t')
        kv = dict(x.split('=', 1) for x in f[3:] if '=' in x)
        key = (f[2], kv['nm'], kv['idx'], kv['pos'], kv['ek'])
        if fam == 'VX':
            key = key + (kv.get('IP', ''), kv.get('CAR', ''))
        d[key][kv['ACT']] += 1
    return d

def score(g, p, q):
    res = collections.Counter(); rows = []
    for k in sorted(set(g) | set(p) | set(q)):
        G, P, Q = g.get(k, collections.Counter()), p.get(k, collections.Counter()), q.get(k, collections.Counter())
        if not G:
            res['NOGOLD'] += 1
            if P != Q:
                res['NOGOLD_MOVED'] += 1
                rows.append(('NOGOLD_MOVED', k, G, P, Q))
            continue
        if not P and not Q:
            res['GOLDENONLY'] += 1; continue
        if P == Q:
            res['SAME_AGREE' if P == G else 'STILLWRONG'] += 1
            if P != G: rows.append(('STILLWRONG', k, G, P, Q))
            continue
        if P != G and Q == G:
            res['TOGOLD'] += 1; rows.append(('TOGOLD', k, G, P, Q))
        elif P == G and Q != G:
            res['AWAY'] += 1; rows.append(('AWAY', k, G, P, Q))
        else:
            # both wrong but different -- CLOSER only if the multiset distance
            # to golden strictly fell, otherwise it is a MOVEDWRONG.
            dp = sum(((P - G) + (G - P)).values())
            dq = sum(((Q - G) + (G - Q)).values())
            res['MOVEDCLOSER' if dq < dp else ('MOVEDWRONG' if dq > dp else 'MOVEDSIDEWAYS')] += 1
            rows.append(('MOVEDCLOSER' if dq < dp else ('MOVEDWRONG' if dq > dp else 'MOVEDSIDEWAYS'), k, G, P, Q))
    return res, rows

if __name__ == '__main__':
    verbose = '-v' in sys.argv
    args = [a for a in sys.argv[1:] if a != '-v']
    for fam in ('VX', 'V0'):
        g = load(args[0], fam); p = load(args[1], fam)
        q = load(args[2], fam) if len(args) > 2 else p
        res, rows = score(g, p, q)
        if verbose:
            for t, k, G, P, Q in rows:
                print("[%s %s] %s" % (fam, t, ' | '.join(map(str, k))))
                print("     G:%s P:%s Q:%s" % (dict(G), dict(P), dict(Q)))
        print("-- %s " % fam + "  ".join("%s=%d" % (k, v) for k, v in sorted(res.items())))
