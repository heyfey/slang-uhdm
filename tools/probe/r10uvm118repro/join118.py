#!/usr/bin/env python3
"""r10uvm118 — MULTISET join of two ct118cen censuses (LHS is ALWAYS golden).

A last-writer dict DROPS rows whose keys collide (a measurement law of this
campaign), so both sides are counted as MULTISETS and the join is done on the
counts.  Output:

  BOTH-SAME     key present on both sides with the SAME payload
  MOVED-WRONG   key on both sides, payload DIFFERS      (golden | ours)
  OURS-ONLY     key only in ours   (we emit an object golden does not)
  GOLDEN-ONLY   key only in golden (golden emits an object we do not)

usage: join118.py <golden.tsv> <ours.tsv> [--detail]
"""
import sys, collections

def load(p):
    m = collections.Counter()
    pay = collections.defaultdict(collections.Counter)
    for ln in open(p):
        ln = ln.rstrip('\n')
        if not ln: continue
        k, _, v = ln.partition('\t||\t')
        m[k] += 1
        pay[k][v] += 1
    return m, pay

def main():
    g, gp = load(sys.argv[1])
    o, op = load(sys.argv[2])
    detail = '--detail' in sys.argv
    both_same = both_diff = 0
    ours_only = collections.Counter()
    gold_only = collections.Counter()
    moved = collections.Counter()
    for k in set(g) | set(o):
        gc, oc = g.get(k, 0), o.get(k, 0)
        common = min(gc, oc)
        if gc > oc: gold_only[k] += gc - oc
        if oc > gc: ours_only[k] += oc - gc
        if common:
            gpay, opay = gp[k], op[k]
            inter = sum(min(gpay[v], opay[v]) for v in set(gpay) & set(opay))
            same = min(inter, common)
            both_same += same
            if common - same:
                both_diff += common - same
                moved[k + '\t||\tGOLD=' + ';'.join(sorted(gpay)) + '\tOURS=' +
                      ';'.join(sorted(opay))] += common - same
    print(f"BOTH-SAME   {both_same}")
    print(f"MOVED-WRONG {both_diff}")
    print(f"OURS-ONLY   {sum(ours_only.values())}")
    print(f"GOLDEN-ONLY {sum(gold_only.values())}")
    if detail:
        for tag, c in (('MOVED-WRONG', moved), ('OURS-ONLY', ours_only),
                       ('GOLDEN-ONLY', gold_only)):
            for k, n in sorted(c.items()):
                print(f"{tag}\t{n}\t{k}")

main()
