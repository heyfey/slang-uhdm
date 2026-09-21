#!/bin/bash
# r11u81 ROW JOIN — compare a sweep CSV against a baseline on (name,mode),
# printing every row whose STATUS or DUMP column differs, plus the histograms.
# A name+mode present on one side only is printed as ONLY-A / ONLY-B and
# counted; a join that silently drops rows reads exactly like a clean run.
#
#   usage: rowjoin81.sh <new.csv> <baseline.csv> [label]
set -u
N=${1:?new}; B=${2:?baseline}; L=${3:-join}
python3 - "$N" "$B" "$L" <<'PY'
import csv, sys
n, b, lab = sys.argv[1], sys.argv[2], sys.argv[3]
def rd(p):
    out = {}
    with open(p) as f:
        for r in csv.DictReader(f):
            out[(r['name'], r['mode'])] = (r['status'], r.get('dump', ''))
    return out
A, C = rd(n), rd(b)
diff = onlyA = onlyB = 0
for k in sorted(set(A) | set(C)):
    if k not in C:
        print('  ONLY-NEW  %-40s %s %s' % (k[0] + '/' + k[1], *A[k])); onlyA += 1
    elif k not in A:
        print('  ONLY-BASE %-40s %s %s' % (k[0] + '/' + k[1], *C[k])); onlyB += 1
    elif A[k] != C[k]:
        print('  DIFF      %-40s new=%s/%s base=%s/%s'
              % (k[0] + '/' + k[1], A[k][0], A[k][1], C[k][0], C[k][1])); diff += 1
h = {}
for v in A.values():
    h[v[0]] = h.get(v[0], 0) + 1
hd = {}
for v in A.values():
    hd[v[1]] = hd.get(v[1], 0) + 1
print('%s: rows=%d base=%d DIFF=%d ONLY-NEW=%d ONLY-BASE=%d' %
      (lab, len(A), len(C), diff, onlyA, onlyB))
print('  status ' + ' '.join('%s=%d' % kv for kv in sorted(h.items())))
print('  dump   ' + ' '.join('%s=%d' % kv for kv in sorted(hd.items())))
PY
