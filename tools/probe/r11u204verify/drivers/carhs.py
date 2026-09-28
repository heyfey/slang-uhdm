#!/usr/bin/env python3
"""carhs.py <uhdm>...: per database, every cont_assign record of the strict walk (uhdm-strictcmp self-dump) with its
direct children (type name line:col decompile value), to read which calls a producer folded or kept.  Case scratch only."""
import os, sys, subprocess
SC = os.environ['STRICT_CMP']
for u in sys.argv[1:]:
    t = f'/tmp/r11u204_carhs_{os.getpid()}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    R = [l.rstrip('\n').split('\t') for l in open(t, errors='replace') if l[:1].isdigit()]
    os.remove(t)
    print('==', u)
    for i, r in enumerate(R):
        if r[1] != 'cont_assign': continue
        d = int(r[0]); kids = []
        for s in R[i+1:]:
            if int(s[0]) <= d: break
            if int(s[0]) == d + 1: kids.append(f'{s[1]}({s[2]}) {s[6]}:{s[7]} dec={s[10]} val={s[12]}')
        print(f'  ca {r[6]}:{r[7]} depth{d} | ' + ' || '.join(kids))
