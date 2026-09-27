#!/usr/bin/env python3
# enter.py <P.strict> <L.strict>: record-level movement of one case-mode between two binaries (strictcmp --max
# output, same golden): LEAVE = differing in P only, ENTER = differing in L only, SAME/CHANGED = in both (the B
# side equal / different).  A record is keyed by its walk number (the golden side's order).
import sys
def load(fn):
    L = open(fn).read().split('\n'); d = {}
    for i in range(len(L) - 2):
        if L[i].startswith('#') and L[i+1].strip().startswith('A:'):
            d[L[i].split()[0]] = (L[i+1].split('A: ',1)[1], L[i+2].split('B: ',1)[1])
    return d
P, Q = load(sys.argv[1]), load(sys.argv[2])
leave = [k for k in P if k not in Q]; enter = [k for k in Q if k not in P]
chg = [k for k in P if k in Q and P[k][1] != Q[k][1]]
print(f'LEAVE {len(leave)} ENTER {len(enter)} CHANGED {len(chg)} SAME {len([k for k in P if k in Q]) - len(chg)}')
for k in enter: print('  ENTER', k, Q[k][0][:90].replace('\t','|'), '|| B', Q[k][1][:90].replace('\t','|'))
