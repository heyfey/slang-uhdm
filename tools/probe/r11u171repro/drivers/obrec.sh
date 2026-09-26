#!/bin/bash
# obrec.sh <golden.uhdm> <a.uhdm> <b.uhdm> : ORDER-BLIND record difference between two of OUR databases of one row:
# uhdm-strictcmp's per-object records of each (dumped against the row's golden, depth dropped) as multisets; prints
# per record type how many records only A / only B holds, and how many A-only/B-only pairs differ in the file
# column alone.  (Two of ours are not compared directly: the UVM order coin makes stage 1 refuse the pair.)
T=$(mktemp -d /tmp/r11u171_scr/obrec.XXXX)
S=${STRICT_CMP:-/tmp/r11u171_bin/uhdm-strictcmp}
$S --max 0 --dump-a $T/g --dump-b $T/a "$1" "$2" > /dev/null 2>&1
$S --max 0 --dump-a $T/g2 --dump-b $T/b "$1" "$3" > /dev/null 2>&1
python3 - $T/a $T/b <<'PY'
import sys, collections
def load(p): return collections.Counter(l.rstrip('\n').split('\t', 1)[1] for l in open(p) if '\t' in l)
a, b = load(sys.argv[1]), load(sys.argv[2])
oa, ob = a - b, b - a
bytype = collections.Counter()
for k, v in oa.items(): bytype[('A', k.split('\t')[0])] += v
for k, v in ob.items(): bytype[('B', k.split('\t')[0])] += v
def nofile(k):
    f = k.split('\t')
    if len(f) > 4: f[4] = '*'
    return '\t'.join(f)
na = collections.Counter(); nb = collections.Counter()
for k, v in oa.items(): na[nofile(k)] += v
for k, v in ob.items(): nb[nofile(k)] += v
print('recordsA=%d recordsB=%d onlyA=%d onlyB=%d file-only pairs=%d' % (sum(a.values()), sum(b.values()), sum(oa.values()), sum(ob.values()), sum((na & nb).values())))
for (s, t), v in sorted(bytype.items()): print('  %s %s %d' % (s, t, v))
PY
rm -rf $T
