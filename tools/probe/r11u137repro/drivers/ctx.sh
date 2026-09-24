#!/bin/bash
# ctx.sh corpus/mode/name idx [before] [after]  -> record window golden/ours from pristine dumps
D=${DUMPS:-/tmp/r11u137_dumpsP}
python3 - $D/$1 $2 ${3:-8} ${4:-3} <<'PY'
import sys
b=sys.argv[1]; i=int(sys.argv[2]); pre=int(sys.argv[3]); post=int(sys.argv[4])
def rd(f): return [l.rstrip('\n').split('\x1f')[0].replace('\t','|') for l in open(f,encoding='utf-8',errors='replace')]
A=rd(b+'.a'); B=rd(b+'.b')
for j in range(max(0,i-pre), i+post+1):
    a=A[j] if j<len(A) else ''; bb=B[j] if j<len(B) else ''
    print(('>' if j==i else ' ')+str(j),'G',a[:170]); 
    if a!=bb: print(' '*len(str(j))+'  O',bb[:170])
PY
