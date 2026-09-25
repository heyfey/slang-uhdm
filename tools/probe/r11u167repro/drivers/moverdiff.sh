#!/bin/bash
# moverdiff.sh <law sweep> <pristine sweep> <corpus> <mode> <test>: the strict comparator's full
# differing-record sets (--max 100000) of the pristine and the law database of one sweep row against
# the same golden; prints the verdicts and the records that LEAVE / ENTER.
# FAIL-CLOSED on $FENCED: refuses to run without the four names and refuses a fenced test.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "moverdiff.sh: export FENCED (four names) first" >&2; exit 1; }
L=$1; P=$2; C=$3; M=$4; T=$5
for f in $FENCED; do [ "$T" = "$f" ] && { echo "moverdiff.sh: fenced test refused" >&2; exit 1; }; done
SC=${SC:-/tmp/r11u167_bin/strictcmp_raw}; W=/tmp/r11u167_md; mkdir -p $W
dl=$(ls -d $L/$C/$M/$T-* | head -1); dp=$(ls -d $P/$C/$M/$T-* | head -1)
g=$(grep -o 'golden cache hit [^)]*' $dp/cmds.txt | awk '{print $4}')/golden.uhdm
$SC --max 100000 $g $dp/slang.uhdm > $W/p.txt 2>&1; $SC --max 100000 $g $dl/slang.uhdm > $W/l.txt 2>&1
echo "$C $M $T | pristine: $(tail -1 $W/p.txt) | law: $(tail -1 $W/l.txt)"
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
a=recs(w+'/p.txt'); b=recs(w+'/l.txt')
for k,x in sorted(a-b)[:6]: print(f"  LEAVE {k} {x}")
for k,x in sorted(b-a)[:6]: print(f"  ENTER {k} {x}")
print(f"  leave={len(a-b)} enter={len(b-a)}")
PY
