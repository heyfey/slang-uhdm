#!/usr/bin/env python3
"""caseaway.py <golden.uhdm> <pristine.uhdm> <law.uhdm>: the chain-keyed away census of one case-view (awayrows.py's
record model on one triple: each database's records from the variant comparator walking it against itself, keyed
by the ancestor chain, the raw full name in the record), usable where the strict comparator stops at stage 1.
Prints `away=<n> toward=<n>` (the swapped call is the positive control).  $SCX or $B/strictcmp_x."""
import os, sys, subprocess, collections, tempfile
SC = os.environ.get('SCX') or os.path.join(os.environ['B'], 'strictcmp_x')
def keyed(u):
    t = tempfile.mktemp(prefix='r11u224_ca_', dir=os.environ.get('S', '/tmp'))
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        d = int(f[0]); st = st[:d]
        ck[(' < '.join(reversed(st)), '|'.join(f[1:]))] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck
G, P, L = (keyed(x) for x in sys.argv[1:4])
print(f'away={sum(((P & G) - L).values())} toward={sum(((L & G) - P).values())}')
