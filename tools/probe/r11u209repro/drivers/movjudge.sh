#!/bin/bash
# r11u209: judge byte-control movers (parse form): case.sh with the pristine and the law binary, the verdicts, the laws
# that fired (R11U209_TRACE), and the order-blind lost/gained record counts against golden (away.py's measure on case
# records). usage: movjudge.sh <mover list: one repo-relative case dir per line> <outdir>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
L=$1; O=$2; mkdir -p $O
while read -r c; do
  echo "$c" | grep -Pqw "$FENCE_RE" && { echo "$c FENCED-REFUSED"; continue; }
  rp=$(bash $HERE/case.sh $REPO/$c pris $B/pris.bin); rl=$(bash $HERE/case.sh $REPO/$c law8 $B/law8.bin)
  k=$(echo $c | sed 's#/#__#g'); mkdir -p $O/tr_$k
  (cd $REPO/$c && R11U209_TRACE=$O/tr_$k $B/law8.bin dut.sv --single-unit --nobuiltin -o $O/tr_$k/o.uhdm > /dev/null 2>&1)
  laws=$(cat $O/tr_$k/*.209 $O/tr_$k/*.205 2>/dev/null | grep -v '^OUT' | awk '{print $1}' | sort -u | tr '\n' ',')
  rel=$(echo $rp | awk '{print $1}'); w=${GW:-/tmp/r11u209_g}/$rel
  la=$(python3 - $w <<'PY'
import sys, collections, os
w = sys.argv[1]
def ms(p):
    c = collections.Counter()
    if os.path.exists(p):
        for l in open(p, errors='replace'):
            if '\t' in l: c[l.rstrip('\n').split('\t', 1)[1]] += 1
    return c
G, P, L = ms(w + '/pris.a.rec'), ms(w + '/pris.b.rec'), ms(w + '/law8.b.rec')
shared, kept = G & P, G & L
print('lost=%d gained=%d' % (sum((shared - kept).values()), sum((kept - shared).values())))
PY
)
  vp=$(echo $rp | grep -o 'strict=[^ ]*' | sed 's/strict=//; s/_[0-9]*_objects//'); vl=$(echo $rl | grep -o 'strict=[^ ]*' | sed 's/strict=//; s/_[0-9]*_objects//')
  cp=$(echo $rp | grep -o 'cmp=[0-9]*'); cl=$(echo $rl | grep -o 'cmp=[0-9]*')
  echo "$c $cp/$cl $vp -> $vl $la laws=$laws"
done < $L
