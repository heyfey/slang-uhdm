#!/bin/bash
# obdiff.sh <case scratch dir> <tagA> <tagB>: order-blind uhdm-dump comparison of two exports of one case against its
# golden (ids and directories stripped): prints the lines golden has that A lacks but B has (B gained), that B lacks
# but A has (B lost), and ours-only lines that B added / removed.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "obdiff.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
w=$1; a=$2; b=$3
norm() { $UHDM_DUMP $1 2>/dev/null | sed 1d | sed -E 's/, id:[0-9]+//g; s#/[^ ,:()]*/##g' | sed 's/^ *//' | sort; }
g=$(ls $w/gold_*/golden.uhdm | head -1)
norm $g > $w/ob.g; norm $w/$a.uhdm > $w/ob.$a; norm $w/$b.uhdm > $w/ob.$b
python3 - $w/ob.g $w/ob.$a $w/ob.$b <<'PY'
import sys, collections
G, A, B = (collections.Counter(open(f).read().splitlines()) for f in sys.argv[1:4])
ga, gb = G - A, G - B          # golden lines missing in A / in B
oa, ob = A - G, B - G          # ours-only lines
print(f'dist A={sum((ga+oa).values())} B={sum((gb+ob).values())}')
for t, c in (('golden line B lost (A had it)', gb - ga), ('golden line B gained', ga - gb), ('ours-only line B added', ob - oa), ('ours-only line B removed', oa - ob)):
    for l, n in c.items(): print(f'  {t}: {n}x {l[:200]}')
PY
