#!/usr/bin/env python3
"""recchain.py <golden.uhdm> <a.uhdm> <b.uhdm> [regex on the record]: strict records (uhdm-strictcmp --dump-a of each
database against itself, walk order with depth) keyed by their ancestor chain (type:name of every enclosing record,
from the depth column), as multisets; prints, for the records matching the regex, the keyed records where a and b
differ, with the golden / a / b counts.  Reads only the three databases given (r11u182)."""
import sys, subprocess, collections, re, os, tempfile
SC = os.environ.get('STRICT_CMP', '/tmp/r11u182_bin/uhdm-strictcmp')
def keyed(u):
    t = tempfile.mktemp(prefix='r11u182_rc_')
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    c = collections.Counter(); stack = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 3: continue
        d = int(f[0]); stack = stack[:d]
        chain = ' < '.join(reversed(stack))
        c[(chain, '|'.join(f[1:]))] += 1
        stack.append(f'{f[1]}:{f[2]}')
    os.remove(t); return c
G, A, B = keyed(sys.argv[1]), keyed(sys.argv[2]), keyed(sys.argv[3])
rx = re.compile(sys.argv[4]) if len(sys.argv) > 4 else None
for k in sorted(set(A) | set(B)):
    if A[k] == B[k]: continue
    if rx and not rx.search(k[1]): continue
    print(f'g={G[k]} a={A[k]} b={B[k]}  {k[1][:120]}  @ {k[0][:260]}')
