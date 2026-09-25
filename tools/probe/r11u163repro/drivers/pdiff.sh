#!/bin/bash
# pdiff.sh <probe case rel path under tests/probe> <binA> <binB>: both binaries' databases of one probe
# case against its cached golden (scripts/check_probe.py's cache key), and the strict comparator's own
# differing-record lists (--max 100000): prints the records that LEAVE (differ on A only) and ENTER
# (differ on B only), keyed by walk index + field + record text.
R=$(cd $(dirname $0)/../../../.. && pwd); rel=$1; A=$2; B=$3
W=/tmp/r11u163_pd/$(echo $rel | tr / _); mkdir -p $W
SC=${SC:-/tmp/r11u163_x/strictcmp_raw}
c=$R/tests/probe/$rel
g=$(cd $R/scripts && python3 -c "import sys; import check_probe as cp; print(cp.cache_dir(sys.argv[1]))" "$rel")/golden.uhdm
[ -s "$g" ] || { echo "no golden $g"; exit 1; }
for t in A B; do b=${!t}; rm -f $W/$t.uhdm; (cd $c && $b dut.sv --single-unit --nobuiltin -o $W/$t.uhdm >/dev/null 2>&1)
  $SC --max 100000 $g $W/$t.uhdm > $W/$t.strict 2>&1; done
echo "A: $(tail -1 $W/A.strict)  B: $(tail -1 $W/B.strict)"
python3 - $W <<'PY'
import sys
w=sys.argv[1]
def recs(f):
    out=set(); L=open(f).read().split('\n'); i=0
    while i < len(L):
        if L[i].startswith('#') and i+2 < len(L):
            out.add((L[i], L[i+2].strip())); i+=3
        else: i+=1
    return out
a=recs(w+'/A.strict'); b=recs(w+'/B.strict')
for k,x in sorted(a-b)[:12]: print(f"LEAVE {k} {x}")
for k,x in sorted(b-a)[:12]: print(f"ENTER {k} {x}")
print(f"leave={len(a-b)} enter={len(b-a)}")
PY
