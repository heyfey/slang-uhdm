#!/usr/bin/env python3
"""r10earl92 — MEASUREMENT-ONLY scorer for ct92cen rows.

MULTISET join (keys collide — a last-writer dict silently drops rows, RESUME
§9).  LHS is ALWAYS golden.  Buckets:

  BOTH-SAME     key present both sides, payload identical
  MOVED-WRONG   key present both sides, payload differs
  GOLDEN-ONLY   key only on golden's side
  OURS-ONLY     key only on our side

and, restricted to the family this pass moves, the four cells RESUME §7 asks
for by name:  WRONG->RIGHT / RIGHT->WRONG / AWAY-GOLDEN / STILL-WRONG are
computed by score3_92.py from a BEFORE and an AFTER run of this one.

usage: score92.py <golden.rows> <ours.rows> [--fam CA|CO] [--dump-diff N]
"""
import sys, collections

def load(path, fam=None):
    d = collections.Counter()
    with open(path) as f:
        for ln in f:
            ln = ln.rstrip('\n')
            if not ln: continue
            if fam and not ln.startswith(fam + '\t'): continue
            k, _, p = ln.partition('\t||\t')
            p = p.partition('\tDIAG\t')[0]   # DIAG fields are NEVER scored
            d[(k, p)] += 1
    return d

def keysplit(c):
    ks = collections.Counter()
    for (k, p), n in c.items(): ks[k] += n
    return ks

def main():
    g, o = sys.argv[1], sys.argv[2]
    fam = None; dump = 0
    a = sys.argv[3:]
    while a:
        if a[0] == '--fam': fam = a[1]; a = a[2:]
        elif a[0] == '--dump-diff': dump = int(a[1]); a = a[2:]
        else: a = a[1:]
    G, O = load(g, fam), load(o, fam)
    gk, ok = keysplit(G), keysplit(O)
    both_same = sum(min(G[c], O[c]) for c in set(G) & set(O))
    gonly_k = sum(max(0, gk[k] - ok.get(k, 0)) for k in gk)
    oonly_k = sum(max(0, ok[k] - gk.get(k, 0)) for k in ok)
    # cells sharing a KEY but not a PAYLOAD
    moved = 0; diffs = []
    for k in set(gk) & set(ok):
        gsub = collections.Counter({p: n for (kk, p), n in G.items() if kk == k})
        osub = collections.Counter({p: n for (kk, p), n in O.items() if kk == k})
        same = sum(min(gsub[p], osub[p]) for p in set(gsub) & set(osub))
        pairable = min(sum(gsub.values()), sum(osub.values()))
        m = pairable - same
        moved += m
        if m and len(diffs) < dump:
            diffs.append((k, dict(gsub), dict(osub)))
    print('FAM=%s  BOTH-SAME %d  MOVED-WRONG %d  GOLDEN-ONLY %d  OURS-ONLY %d'
          % (fam or 'ALL', both_same, moved, gonly_k, oonly_k))
    for k, gs, os_ in diffs:
        print('  KEY %s' % k)
        print('    G %s' % gs)
        print('    O %s' % os_)

main()
