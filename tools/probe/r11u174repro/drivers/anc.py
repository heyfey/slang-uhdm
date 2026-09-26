#!/usr/bin/env python3
# anc.py <recfile> <regex>: for each record matching regex, print record# and its depth-1..3 ancestors (walk-depth parent chain)
import sys, re
L = open(sys.argv[1]).read().split('\n'); rx = re.compile(sys.argv[2])
for i, l in enumerate(L):
    if not l or not rx.search(l): continue
    d = int(l.split('\t')[0]); ch = []
    for j in range(i - 1, -1, -1):
        r = L[j].split('\t')
        if int(r[0]) < d:
            ch.append('%s:%s' % (r[1], r[2] or r[4])); d = int(r[0])
            if d <= 1: break
    f = l.split('\t'); print('#%d %s %s | %s' % (i, f[1], f[4], ' < '.join(reversed(ch))))
