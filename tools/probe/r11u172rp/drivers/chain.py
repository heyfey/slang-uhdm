#!/usr/bin/env python3
# chain.py <recfile> <idx> [...]: print the parent chain (by walk depth) of record #idx (1-based line number)
import sys
lines = open(sys.argv[1]).read().split('\n')
for a in sys.argv[2:]:
    i = int(a)  # strictcmp record #N is 0-based = line N+1
    rec = lines[i].split('\t'); d = int(rec[0]); out = [lines[i]]
    for j in range(i - 1, -1, -1):
        r = lines[j].split('\t')
        if int(r[0]) < d:
            out.append(lines[j]); d = int(r[0])
            if d == 0: break
    print('#%s' % a)
    for o in reversed(out):
        f = o.split('\t'); print('   ' + ' | '.join(x for x in f if x != ''))
