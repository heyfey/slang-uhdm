#!/bin/bash
# r11u219: the downstream face control. Every case dir holding a dut.sv under the given trees (fence-checked by
# dscases.py) through the gate's own one(), with the pristine binary and the law binary ($B/pristine, $B/$LAWBIN),
# three parallel chunks, a fresh GOLDEN_CACHE under $S. Prints '<case> <pristine verdict> -> <law verdict> <law differs>'.
# usage: dsfaces.sh <tree>... > faces.txt
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
[ -n "$S" ] && [ -n "$LAWBIN" ] || { echo "dsfaces.sh: export S and LAWBIN" >&2; exit 2; }
export GOLDEN_CACHE=$S/gc; mkdir -p $S/lists
for t in "$@"; do find "$(realpath $t)" -name dut.sv -printf '%h\n'; done | sort -u > $S/lists/all
rm -f $S/lists/part.*; split -n l/3 $S/lists/all $S/lists/part.
for b in pristine $LAWBIN; do
  for p in $S/lists/part.a?; do python3 $HERE/dscases.py $B/$b $S/wr_$b $(cat $p) > $p.$b.out 2>&1 & done; wait
done
python3 - "$S/lists" "$LAWBIN" <<'PY'
import sys, glob, ast
d, law = sys.argv[1], sys.argv[2]
def ld(b):
    r = {}
    for f in sorted(glob.glob(f'{d}/part.a?.{b}.out')):
        for l in open(f):
            c, _, rest = l.partition(' ')
            try: x = ast.literal_eval(rest.strip()); r[c] = (x['verdict'], x['differs'])
            except Exception: r[c] = ('PARSE', rest.strip()[:80])
    return r
P, L = ld('pristine'), ld(law)
for c in sorted(set(P) | set(L)):
    print(c, P.get(c, ('-',))[0], '->', L.get(c, ('-', ''))[0], L.get(c, ('', ''))[1])
PY
