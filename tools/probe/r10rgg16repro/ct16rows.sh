#!/usr/bin/env bash
# r10rgg16/ct16rows.sh — count DIFFERING ROWS between two verify_golden CSVs,
# on the STATUS column AND on the DUMP column, keyed (name,mode).  A row present
# on one side only is DIFFERING.  Prints every differing row.
#   usage: ct16rows.sh <a.csv> <b.csv>
set -u
python3 - "$1" "$2" <<'PY'
import csv,sys
def rd(p):
    d={}
    with open(p, newline='') as f:
        for r in csv.DictReader(f):
            d[(r['name'],r['mode'])]=(r['status'],r.get('dump',''))
    return d
a=rd(sys.argv[1]); b=rd(sys.argv[2])
ks=sorted(set(a)|set(b)); n=0
for k in ks:
    if a.get(k)!=b.get(k):
        n+=1; print("DIFF",k,a.get(k),"->",b.get(k))
print("rows_a=%d rows_b=%d differing=%d"%(len(a),len(b),n))
PY
