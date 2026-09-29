#!/usr/bin/env python3
"""vaway1.py <golden.uhdm> <off.uhdm> <on.uhdm>: map 13's self-keyed away census (each database walked against
itself by the variant comparator $SCX, raw full names), for pairs the strict comparator stops at stage 1.
Prints: away toward flat_away flat_toward (chain-keyed = each record keyed by its ancestor chain)."""
import os, sys, subprocess, collections, tempfile
SC = os.environ['SCX']
def keyed(u):
    t = tempfile.mktemp(prefix='v11u220_aw_')
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        d = int(f[0]); st = st[:d]
        rec = '|'.join(f[1:]); ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck, fl
(G, Gf), (O, Of), (N, Nf) = [keyed(x) for x in sys.argv[1:4]]
aw = (O & G) - N; tw = (N & G) - O; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
print(f'away={sum(aw.values())} toward={sum(tw.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())}')
for k in list(aw)[:3]: print('  AWAY', (k[1] + ' @ ' + k[0])[:300])
