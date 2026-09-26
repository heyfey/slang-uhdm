#!/usr/bin/env python3
# recanc.py <a.txt> <b.txt> <strict.txt>: for every differing record number listed in strict.txt, the ancestors (depth<=3) in A
import sys, re
A = open(sys.argv[1]).read().split('\n'); B = open(sys.argv[2]).read().split('\n')
ids = [int(m.group(1)) for m in re.finditer(r'^#(\d+) ', open(sys.argv[3]).read(), re.M)]
for i in ids:
    l = A[i]; d = int(l.split('\t')[0]); ch = []
    for j in range(i - 1, -1, -1):
        r = A[j].split('\t')
        if int(r[0]) < d:
            ch.append('%s:%s' % (r[1], r[2] or r[4])); d = int(r[0])
            if d <= 0: break
    fa = A[i].split('\t'); fb = B[i].split('\t') if i < len(B) else []
    print('#%d %s | A=%s B=%s | %s' % (i, fa[1], fa[4] or '/'.join(fa[5:10]), (fb[4] or '/'.join(fb[5:10])) if fb else '-', ' < '.join(reversed(ch))[:260]))
