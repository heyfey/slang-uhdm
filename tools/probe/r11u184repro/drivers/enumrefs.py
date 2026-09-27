#!/usr/bin/env python3
# enumrefs.py <a.txt> <b.txt>: every ref_obj whose next walk record is an enum_const one level down, with the
# enum_const's location in golden (A) and ours (B); the record dumps come from uhdm-strictcmp --dump-a/--dump-b.
import sys
def recs(p):
    return [l.rstrip('\n').split('\t') for l in open(p)]
A, B = recs(sys.argv[1]), recs(sys.argv[2])
if len(A) != len(B):
    print('WALK-LEN-DIFFERS', len(A), len(B))
for i in range(min(len(A), len(B)) - 1):
    a, b = A[i], B[i]
    if a[1] == 'ref_obj' and A[i+1][1] == 'enum_const' and int(A[i+1][0]) == int(a[0]) + 1:
        ea, eb = A[i+1], B[i+1]
        la = '%s:%s-%s:%s' % tuple(ea[6:10]); lb = '%s:%s-%s:%s' % tuple(eb[6:10]) if eb[1] == 'enum_const' else eb[1]
        ctx = ' '.join(A[j][1] for j in range(i-1, max(-1, i-6), -1) if int(A[j][0]) < int(a[0]))
        print('%s ref %s:%s %-6s gold=%s ours=%s %s' % (a[0], a[6], a[7], a[2], la, lb, 'SAME' if la == lb else 'DIFF'))
