#!/bin/bash
# rowrec.sh <corpus> <mode> <name> <wdA> <wdB>: strict record sets of two sweep databases against the row's golden (fence-guarded)
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "export FENCED" >&2; exit 1; }
c=$1; m=$2; n=$3; A=$4; B=$5
for f in $FENCED; do [ "$n" = "$f" ] && { echo "fenced: refusing" >&2; exit 1; }; done
da=$(ls -d $A/$c/$m/$n-*/ | head -1); db=$(ls -d $B/$c/$m/$n-*/ | head -1)
g=$(grep -o 'golden cache hit [^)]*' $da/cmds.txt | awk '{print $4}'); [ -d "$g" ] && g=$(find $g -name '*.uhdm' | head -1)
[ -f "$g" ] || { echo "no golden for $n ($g)"; exit 1; }
S=/tmp/v11u158_bin/uhdm-strictcmp; t=/tmp/v11u158_rr; mkdir -p $t
$S --max 100000 --dump-a $t/ga.txt --dump-b $t/a.txt $g $da/slang.uhdm > $t/sa.txt 2>&1
$S --max 100000 --dump-a $t/gb.txt --dump-b $t/b.txt $g $db/slang.uhdm > $t/sb.txt 2>&1
echo "$n $m: A $(tail -1 $t/sa.txt) [$(grep '^fields' $t/sa.txt)] | B $(tail -1 $t/sb.txt) [$(grep '^fields' $t/sb.txt)]"
python3 - $t <<'PY'
import sys
t=sys.argv[1]
def d(x,y):
    a=open(f'{t}/{x}').read().splitlines(); b=open(f'{t}/{y}').read().splitlines()
    return {(i,q) for i,(p,q) in enumerate(zip(a,b)) if p!=q}, len(a), len(b)
A,la,lb=d('ga.txt','a.txt'); B,la2,lb2=d('gb.txt','b.txt')
ia={i for i,_ in A}; ib={i for i,_ in B}
print(f'  walk-aligned differing records: A {len(A)} (objs {la}/{lb}), B {len(B)} (objs {la2}/{lb2}); leave {len(ia-ib)} enter {len(ib-ia)} both {len(ia&ib)} (same text {len(A&B)})')
PY
