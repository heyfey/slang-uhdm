#!/usr/bin/env python3
"""r10earl117 — the BY-ROW mover prediction, from PRISTINE censuses ONLY.

MEASUREMENT ONLY.  Written and frozen BEFORE the patched sweep is scored, so
the prediction cannot be fitted to the answer.

It selects the cells the STATED gate admits, using only what a sig117 row can
see:
    POS == idx        a bit_select's index (the law's site)
    SK  == bit_select
    PAT >  0          inside an assignment-pattern operand value
    SIDE == R         the carrier's Rhs (a pattern Lhs never raises PAT)
    CAR == cont_assign and SC == gen_scope     gate (a)
    ours is a ref_obj bound to a `parameter`   still-a-ref_obj + gate (d)
and prints, per database, how many such cells exist and whether GOLDEN has a
`#64#9` constant at the same key.

`--unbound` drops the `@parameter` requirement, which is what makes the DEF-view
(`default` mode) population visible: there our `ref_obj` has no `Actual_group`
yet, so the bound form hides exactly the cells the def listing carries.

`--anysel` additionally drops the `bit_select` / `idx` restriction, so the scan
covers EVERY select-bound carrier — a `var_select` dimension, a part-select
bound, an indexed-part-select base — inside a gen-scope pattern operand value.
That is the run that proves the carriers this pass does NOT ship have no corpus
population at all.

CAVEAT, stated in the code because it is an UPPER BOUND: a census row cannot
see the USER-CALL-ARGUMENT depth (fence (f)) or `isFromGenvar()` — a cell whose
index is a gen-scope localparam reads `ref_obj|<name>@parameter` here just like
a genvar.  So the printed set is a SUPERSET of the true mover set; the arms and
the golden `#64#9` column are what narrow it.

usage: predict117.py [--unbound] [--anysel] <gold.txt> <pris.txt>
"""
import sys, collections

def load(path):
    per = collections.defaultdict(lambda: collections.defaultdict(collections.Counter))
    for line in open(path):
        if not line.startswith('S|'):
            continue
        f = line.rstrip('\n').split('|')
        if len(f) < 13:
            continue
        per[f[1]][tuple(f[2:11])][tuple(f[11:13])] += 1
    return per

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if len(args) < 2:
        sys.exit(__doc__)
    unbound = '--unbound' in sys.argv or '--anysel' in sys.argv
    anysel = '--anysel' in sys.argv
    G, P = load(args[0]), load(args[1])
    rows = collections.Counter()
    carriers = collections.Counter()
    gold64 = collections.Counter()
    goldother = collections.Counter()
    for db, keys in P.items():
        for key, pay in keys.items():
            span, sk, sname, car, sc, gd, pat, side, pos = key
            if not anysel and (pos != 'idx' or sk != 'bit_select'):
                continue
            if int(pat) <= 0 or side != 'R':
                continue
            if car != 'cont_assign' or sc != 'gen_scope':
                continue
            n = sum(c for (ik, it), c in pay.items()
                    if ik == 'ref_obj' and
                    (unbound or it.endswith('@parameter')))
            if not n:
                continue
            rows[db] += n
            carriers[(sk, pos)] += n
            gp = G.get(db, {}).get(key)
            if gp and all(ik == 'constant' and it.endswith('#64#9')
                          for (ik, it) in gp):
                gold64[db] += n
            else:
                goldother[db] += n
    print("PREDICTED CANDIDATE CELLS (upper bound), by database"
          "  [unbound=%s anysel=%s]" % (unbound, anysel))
    for db in sorted(rows, key=lambda d: -rows[d]):
        print("  %-46s cells=%-5d golden#64#9=%-5d golden-other=%d" %
              (db, rows[db], gold64[db], goldother[db]))
    print("TOTAL databases=%d cells=%d golden#64#9=%d golden-other=%d" %
          (len(rows), sum(rows.values()), sum(gold64.values()),
           sum(goldother.values())))
    if anysel:
        print("BY CARRIER (select kind | bound position):")
        for (sk, pos), n in sorted(carriers.items(), key=lambda x: -x[1]):
            print("  %-30s cells=%d" % (sk + '|' + pos, n))

if __name__ == '__main__':
    main()
