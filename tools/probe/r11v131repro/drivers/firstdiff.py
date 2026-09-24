#!/usr/bin/env python3
# firstdiff.py <golden> <a> <b> : first differing record index + objects_differing for a and b
import subprocess, sys, re
SC='/tmp/v11u131_bin/strictcmp'
def fd(g, o):
    r = subprocess.run([SC, g, o], capture_output=True, text=True).stdout
    m = re.search(r'^#(\d+) (\S+)', r, re.M); od = re.search(r'objects_differing=(\d+)', r)
    last = (r.strip().splitlines() or [''])[-1]
    if 'STRICT_EQUAL' in last: return (10**9, 'equal', 0)
    return (int(m.group(1)) if m else -1, m.group(2) if m else last, int(od.group(1)) if od else -1)
g, a, b = sys.argv[1:4]
A = fd(g, a); B = fd(g, b)
tag = 'EARLIER' if B[0] < A[0] else ('SAME_IDX' if B[0] == A[0] else 'LATER')
if tag == 'SAME_IDX' and B[1] == A[1] and B[2] > A[2]: tag = 'MOREOBJ'
print(tag, A, '->', B)
