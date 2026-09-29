#!/bin/bash
# v11u219 (after r11u219repro/drivers/dsfaces.sh): the downstream verdict of every case dir holding a dut.sv under the
# given trees, with $VB/pristine and $VB/$LAWBIN (default law), through the gate's own one(), a fresh GOLDEN_CACHE under
# $S/gc_<tag>.  Prints '<case> <pristine verdict> -> <law verdict> <law differs>'.  usage: dsfaces.sh <tag> <tree>...
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LAWBIN=${LAWBIN:-law}; tag=$1; shift
export GOLDEN_CACHE=$S/gc_$tag; L=$S/ds_$tag; rm -rf $L; mkdir -p $L
for t in "$@"; do find "$(realpath $t)" -name dut.sv -printf '%h\n'; done | sort -u > $L/all
split -n l/3 $L/all $L/part.
for b in pristine $LAWBIN; do
  for p in $L/part.a?; do python3 $HERE/dscases.py $VB/$b $S/wr_${tag}_$b $(cat $p) > $p.$b.out 2>&1 & done; wait
done
python3 - "$L" "$LAWBIN" <<'PY'
import sys, glob, ast
d, law = sys.argv[1], sys.argv[2]
def ld(b):
    r = {}
    for f in sorted(glob.glob(f'{d}/part.a?.{b}.out')):
        for l in open(f):
            c, _, rest = l.partition(' ')
            try: x = ast.literal_eval(rest.strip()); r[c] = (x['verdict'], x.get('differs', ''))
            except Exception: r[c] = ('PARSE', rest.strip()[:80])
    return r
P, L = ld('pristine'), ld(law)
for c in sorted(set(P) | set(L)):
    print(c, P.get(c, ('-',))[0], '->', L.get(c, ('-', ''))[0], L.get(c, ('', ''))[1])
PY
