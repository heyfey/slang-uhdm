#!/usr/bin/env python3
"""compose_rows.py <baseline.csv> <pairA.csv> <law.csv> <combined.csv>: every row whose status or strict verdict
differs from the baseline in any of the three runs, one line each: baseline | pair A alone | law alone | both.
A row is ADDITIVE when both == the one run that moved it (or both moved it the same way)."""
import csv, sys
def load(p):
    d = {}
    with open(p) as f:
        r = csv.reader(f); h = next(r)
        for row in r:
            key = tuple(row[:2]) if h[1] == 'mode' else (row[0],)
            st = row[2] if h[1] == 'mode' else row[1]
            d[key] = st + ' ' + (row[-1] if row[-1] else '')
    return d
b, a, l, c = (load(p) for p in sys.argv[1:5])
for k in sorted(set(b) | set(c)):
    vb, va, vl, vc = b.get(k), a.get(k), l.get(k), c.get(k)
    if vb == va == vl == vc:
        continue
    tag = ('ADDITIVE' if (vc == va and vl == vb) or (vc == vl and va == vb) or (va == vl == vc)
           else 'COMPOSED')
    print(f"{tag}\t{'/'.join(k)}\tbase={vb}\tpairA={va}\tlaw={vl}\tboth={vc}")
