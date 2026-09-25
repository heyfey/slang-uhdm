#!/usr/bin/env python3
# carhs.py DUMP: for every cont_assign record, the first child record (its Rhs as listed; '-' when not listed)
import sys
R=[l.rstrip('\n').split('\t') for l in open(sys.argv[1])]
out=[]
for i,r in enumerate(R):
    if r[1]=='cont_assign':
        d=int(r[0]); c='-'
        if i+1<len(R) and int(R[i+1][0])==d+1:
            n=R[i+1]; c=f"{n[1]}:{n[2]}@{n[6]}.{n[7]}-{n[8]}.{n[9]}:{n[12] if len(n)>12 else ''}/{n[11] if len(n)>11 else ''}"
        out.append(c)
print(' | '.join(out))
