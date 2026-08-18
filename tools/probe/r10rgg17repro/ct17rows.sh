#!/usr/bin/env bash
# r10rgg17repro/ct17rows.sh — differing-row counter over TWO verify_golden CSVs,
# on the STATUS and the DUMP columns both.  Read with python's csv module (the
# committed results/*.csv use \r\n and csv.writer's quoting), never by line.
#   usage: ct17rows.sh <a.csv> <b.csv>
set -u
python3 - "$1" "$2" <<'PY'
import csv, sys
def load(p):
    d={}
    with open(p, newline='') as f:
        for r in csv.DictReader(f):
            d[(r['name'], r['mode'])] = (r['status'], r.get('dump',''))
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
ks=set(a)|set(b)
diff=[k for k in ks if a.get(k)!=b.get(k)]
print("rows_a=%d rows_b=%d shared=%d DIFFERING=%d" % (len(a), len(b), len(set(a)&set(b)), len(diff)))
for k in sorted(diff)[:40]:
    print("  ", k, "A=", a.get(k), "B=", b.get(k))
PY
