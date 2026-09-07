#!/usr/bin/env python3
# r10earl116 -- corpus re-score in r10earl115's element-binding families.
# MEASUREMENT ONLY.  Keys carry the DATABASE, so a moved cell names its row.
import sys, collections
def load(p, fam):
    d = collections.defaultdict(collections.Counter)
    for line in open(p):
        if not line.startswith('ROW'): continue
        f = line.rstrip('\n').split('\t')
        kv = dict(x.split('=',1) for x in f[5:] if '=' in x)
        key = (f[1], f[3], f[4][3:], kv['idx'], kv['pos'], kv['ek'])
        if fam == 'PX':
            key = key + (kv.get('SC',''), kv.get('CAR',''), kv.get('RV',''))
        d[key][kv['ACT']+('/'+kv['ACTNM'] if kv.get('ACTNM') else '')] += 1
    return d
for fam in ('PX','P0'):
    g = load(sys.argv[1], fam); p = load(sys.argv[2], fam); q = load(sys.argv[3], fam)
    res = collections.Counter(); movers = collections.Counter()
    for k in set(g)|set(p)|set(q):
        G,P,Q = set(g.get(k,{})), set(p.get(k,{})), set(q.get(k,{}))
        if not G:
            res['NOGOLD'] += 1
            if P!=Q: res['NOGOLD_MOVED'] += 1; movers[k[0]] += 1
            continue
        if not P and not Q: res['GOLDENONLY'] += 1; continue
        if P==Q:
            res['SAME_AGREE' if P==G else 'STILLWRONG'] += 1; continue
        movers[k[0]] += 1
        if P!=G and Q==G: res['TOGOLD'] += 1
        elif P==G and Q!=G: res['AWAY'] += 1
        else: res['MOVEDWRONG'] += 1
    print("-- %s " % fam + "  ".join("%s=%d"%(k,v) for k,v in sorted(res.items())))
    print("   ROWS WITH MOVED CELLS: %d" % len(movers))
    for db,n in sorted(movers.items()): print("     %-46s cells=%d" % (db,n))
