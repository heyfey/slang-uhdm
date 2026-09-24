#!/bin/bash
# raw.sh <case work dir> <tag> [max] -> differing records with raw full names (strictcmp_x dumps)
w=$1; t=$2
/tmp/r11u137_bin/strictcmp_x --max ${3:-50} --dump-a $w/xg.rec --dump-b $w/x$t.rec $w/golden.uhdm $w/$t.uhdm > $w/x$t.out 2>&1
python3 - $w/xg.rec $w/x$t.rec $w/x$t.out <<'PY'
import sys,re
def rd(f):
    return [l.rstrip('\n').split('\x1f') for l in open(f,encoding='utf-8',errors='replace')]
A=rd(sys.argv[1]);B=rd(sys.argv[2])
out=open(sys.argv[3]).read()
for m in re.finditer(r'^#(\d+) (\S+)',out,re.M):
    i=int(m.group(1))
    a=A[i] if i<len(A) else ['?','']; b=B[i] if i<len(B) else ['?','']
    print('#%d %s'%(i,m.group(2)))
    print('  G:',a[0].replace('\t','|')[:200],' RAW=',a[1])
    print('  O:',b[0].replace('\t','|')[:200],' RAW=',b[1])
PY
tail -2 $w/x$t.out
