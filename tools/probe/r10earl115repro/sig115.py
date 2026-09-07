#!/usr/bin/env python3
"""r10earl115 -- the per-element BINDING scorer.  MEASUREMENT ONLY.

Joins the golden and ours element censuses as a MULTISET on a key that carries
the hier_path SPAN + NAME + the element INDEX/POSITION/KIND, plus the scope,
carrier and root-value matrix, and scores SHAPE (set-of-payloads) exactly the
way r10earl114's cen114.py does:
   TOGOLD / AWAY / MOVEDWRONG / SAME_AGREE / STILLWRONG / NOGOLD / ONESIDED
LHS is ALWAYS golden; RHS is ALWAYS ours.
usage: sig115.py <gold.txt> <pris.txt> [patch.txt]
"""
import sys, collections

def load(p, fam):
    # TWO FAMILIES, on r10earl114's own precedent (the reading key and the
    # scoring key must not be the same key):
    #   PX -- span + name + element index/position/kind + the SCOPE x CARRIER x
    #         ROOT-VALUE matrix (the law's own surface);
    #   P0 -- span + name + element index/position/kind ALONE (coarse), which
    #         is what catches a cell whose ROOT KIND differs between the two
    #         emitters and would otherwise hide as NOGOLD.
    d = collections.defaultdict(collections.Counter)
    for line in open(p):
        if not line.startswith('ROW'): continue
        f = line.rstrip('\n').split('\t')
        kv = dict(x.split('=',1) for x in f[5:] if '=' in x)
        key = (f[3], f[4][3:], kv['idx'], kv['pos'], kv['ek'])
        if fam == 'PX':
            key = key + (kv.get('SC',''), kv.get('CAR',''), kv.get('RV',''))
        d[key][kv['ACT']+('/'+kv['ACTNM'] if kv.get('ACTNM') else '')] += 1
    return d

def score(g, p, q):
    res = collections.Counter(); rows=[]
    for k in sorted(set(g)|set(p)|set(q)):
        G=set(g.get(k,{})); P=set(p.get(k,{})); Q=set(q.get(k,{}))
        if not G:
            res['NOGOLD'] += 1
            if P!=Q: res['NOGOLD_MOVED'] += 1; rows.append(('NOGOLD_MOVED',k,g.get(k),p.get(k),q.get(k)))
            continue
        if not P and not Q: res['GOLDENONLY']+=1; continue
        if P==Q:
            if P==G: res['SAME_AGREE'] += 1
            else:
                res['STILLWRONG'] += 1
                rows.append(('STILLWRONG',k,G,P,Q))
            continue
        # moved
        if P!=G and Q==G: res['TOGOLD']+=1; rows.append(('TOGOLD',k,G,P,Q))
        elif P==G and Q!=G: res['AWAY']+=1; rows.append(('AWAY',k,G,P,Q))
        else: res['MOVEDWRONG']+=1; rows.append(('MOVEDWRONG',k,G,P,Q))
    return res, rows

if __name__ == '__main__':
    verbose = '-v' in sys.argv
    args = [a for a in sys.argv[1:] if a != '-v']
    for fam in ('PX','P0'):
        g = load(args[0], fam); p = load(args[1], fam)
        q = load(args[2], fam) if len(args)>2 else p
        res, rows = score(g,p,q)
        if verbose:
            for t,k,G,P,Q in rows:
                print("[%s %s] %s" % (fam, t, ' | '.join(map(str,k))))
                print("     G:%s  P:%s  Q:%s" % (G,P,Q))
        print("-- %s " % fam + "  ".join("%s=%d"%(k,v) for k,v in sorted(res.items())))
