#!/usr/bin/env python3
"""v91 verifier row comparator: joins two result CSVs on (name,mode) and
reports every row whose STATUS or DUMP column differs. Rows present in only
one side are reported too."""
import csv, sys
def load(p, only_mode=None):
    d = {}
    with open(p, newline='') as f:
        for r in csv.DictReader(f):
            if only_mode and r['mode'] != only_mode: continue
            d[(r['name'], r['mode'])] = (r['status'], r.get('dump',''))
    return d
A = load(sys.argv[1]); B = load(sys.argv[2])
la, lb = sys.argv[3], sys.argv[4]
keys = set(A) | set(B)
diff_status = diff_dump = onlyA = onlyB = 0
for k in sorted(keys):
    a, b = A.get(k), B.get(k)
    if a is None: onlyB += 1; print(f'ONLY-{lb} {k}: {b}'); continue
    if b is None: onlyA += 1; print(f'ONLY-{la} {k}: {a}'); continue
    if a[0] != b[0]:
        diff_status += 1; print(f'STATUS {k}: {la}={a[0]} {lb}={b[0]}')
    if a[1] != b[1]:
        diff_dump += 1; print(f'DUMP   {k}: {la}={a[1]} {lb}={b[1]}')
n = len(keys & set(A) & set(B))
print(f'---- joined={n}  STATUS-DIFF={diff_status}  DUMP-DIFF={diff_dump}  ONLY-{la}={onlyA}  ONLY-{lb}={onlyB}')
