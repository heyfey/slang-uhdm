#!/usr/bin/env python3
# recmv.py <P.strict> <L.strict>: record-level movement (strict output run with a large --max); key = '#n' + golden record
import sys
def load(fn):
    L=open(fn).read().split('\n'); d={}
    for i in range(len(L)-2):
        if L[i].startswith('#') and L[i+1].strip().startswith('A:'):
            k=L[i].split()[0]+' '+L[i+1].split('A: ',1)[1]
            d[k]=L[i+2].split('B: ',1)[1] if 'B: ' in L[i+2] else L[i+2]
    return d
p=load(sys.argv[1]); l=load(sys.argv[2])
leave=[k for k in p if k not in l]; enter=[k for k in l if k not in p]; chg=[k for k in p if k in l and p[k]!=l[k]]
print(f"LEAVE {len(leave)} ENTER {len(enter)} CHANGED {len(chg)}")
for k in leave: print("  LEAVE", k, "| P", p[k])
for k in enter: print("  ENTER", k, "| ours", l[k])
for k in chg: print("  CHG", k, "| P", p[k], "| L", l[k])
