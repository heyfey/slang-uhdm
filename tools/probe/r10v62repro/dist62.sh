#!/usr/bin/env bash
# L1 multiset distance to golden (DEF+ELAB, path-normalised, indent-stripped)
set -u
norm() { awk '/^\\_weaklyReferenced:/{exit} {print}' "$1" \
  | sed -E 's#/[A-Za-z0-9_./+-]*/([A-Za-z0-9_.+-]+\.(sv|svh|vh|v))#\1#g' \
  | sed -E 's/^[[:space:]]+//' | LC_ALL=C sort | uniq -c | awk '{c=$1;$1="";sub(/^ /,"");print $0"\t"c}'; }
T=$(mktemp -d); norm "$1" > $T/g; norm "$2" > $T/p; norm "$3" > $T/q
python3 - $T/g $T/p $T/q <<'PY'
import sys
def load(p):
    d={}
    for l in open(p,errors='replace'):
        k,_,c=l.rstrip('\n').rpartition('\t'); d[k]=int(c)
    return d
g,p,q=(load(a) for a in sys.argv[1:4])
ks=set(g)|set(p)|set(q)
dp=sum(abs(g.get(k,0)-p.get(k,0)) for k in ks)
dq=sum(abs(g.get(k,0)-q.get(k,0)) for k in ks)
print("L1-to-golden pristine=%d patched=%d delta=%+d"%(dp,dq,dq-dp))
PY
rm -rf $T
