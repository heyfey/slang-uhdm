#!/bin/bash
# recdiff.sh <case rel> <tagA> <tagB>: the strict records (--max 100000) of two grid.sh databases of one
# case against its golden, printed as the records that LEAVE (A only) and ENTER (B only).
GW=${GW:-/tmp/r11u167_g}; SC=${SC:-/tmp/r11u167_bin/strictcmp_raw}
w=$GW/$1; g=$w/gold/golden.uhdm
for t in $2 $3; do $SC --max 100000 $g $w/$t.uhdm > $w/$t.full 2>&1; done
python3 - $w/$2.full $w/$3.full <<'PY'
import sys
def recs(f):
    out=set(); L=open(f).read().split('\n'); i=0
    while i < len(L):
        if L[i].startswith('#') and i+2 < len(L):
            out.add((L[i], L[i+2].strip())); i+=3
        else: i+=1
    return out
a=recs(sys.argv[1]); b=recs(sys.argv[2])
for k,x in sorted(a-b)[:6]: print(f"  LEAVE {k} {x[:150]}")
for k,x in sorted(b-a)[:6]: print(f"  ENTER {k} {x[:150]}")
print(f"  leave={len(a-b)} enter={len(b-a)}")
PY
