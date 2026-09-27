#!/usr/bin/env python3
# anc.py <dumpA> <dumpB> <rec#>...: the walk ancestors of strict record #n in both dumps (uhdm-strictcmp --dump-a/-b)
import sys
A = open(sys.argv[1]).read().split('\n'); B = open(sys.argv[2]).read().split('\n')
for r in sys.argv[3:]:
    i = int(r)
    for tag, L in (('A', A), ('B', B)):
        d = int(L[i].split('\t')[0]); out = [L[i]]
        for j in range(i - 1, -1, -1):
            dj = int(L[j].split('\t')[0])
            if dj < d:
                out.append(L[j]); d = dj
                if d == 0: break
        print(f'#{i} {tag}')
        for x in reversed(out): print('   ', x[:170])
