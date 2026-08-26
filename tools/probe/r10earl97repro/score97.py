#!/usr/bin/env python3
"""r10earl97 -- MEASUREMENT ONLY.  MULTISET join of two ct97cen censuses.
Keys collide (many identical typespecs), so both sides are counted as
multisets keyed by KEY, each holding a Counter of PAYLOADs.

  BOTH-SAME     key present both sides, same payload multiset overlap
  MOVED-WRONG   key present both sides, payload differs  (ours != golden)
  GOLDEN-ONLY   key only in golden
  OURS-ONLY     key only in ours
usage: score97.py golden.cen ours.cen [--rows N]
"""
import sys, collections

def load(p):
    d = collections.defaultdict(collections.Counter)
    with open(p) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln: continue
            k, _, v = ln.partition('\t')
            d[k][v] += 1
    return d

def main():
    g, o = load(sys.argv[1]), load(sys.argv[2])
    nrows = 0
    if '--rows' in sys.argv: nrows = int(sys.argv[sys.argv.index('--rows')+1])
    same = wrong = gonly = oonly = 0
    wrows, growsL, orowsL = [], [], []
    for k in set(g) | set(o):
        gc, oc = g.get(k, collections.Counter()), o.get(k, collections.Counter())
        if not oc:
            n = sum(gc.values()); gonly += n
            growsL.append((n, k, dict(gc))); continue
        if not gc:
            n = sum(oc.values()); oonly += n
            orowsL.append((n, k, dict(oc))); continue
        inter = gc & oc
        ns = sum(inter.values()); same += ns
        rg, ro = gc - inter, oc - inter
        nw = max(sum(rg.values()), sum(ro.values()))
        if nw:
            wrong += nw
            wrows.append((nw, k, dict(rg), dict(ro)))
    print(f"BOTH-SAME {same} MOVED-WRONG {wrong} GOLDEN-ONLY {gonly} OURS-ONLY {oonly}")
    if nrows:
        for n, k, rg, ro in sorted(wrows, reverse=True)[:nrows]:
            print(f"  WRONG n={n} {k}  golden={rg} ours={ro}")
        for n, k, d in sorted(growsL, reverse=True)[:nrows]:
            print(f"  GONLY n={n} {k}  {d}")
        for n, k, d in sorted(orowsL, reverse=True)[:nrows]:
            print(f"  OONLY n={n} {k}  {d}")

main()
