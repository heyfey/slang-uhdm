#!/usr/bin/env python3
# caseaway.py <golden> <pris> <law> [v]: chain-keyed and flat away census of one case (records from uhdm-strictcmp self-walk)
import sys, subprocess, collections, os, tempfile
SC = os.environ['STRICT_CMP']
def keyed(u):
    t = tempfile.mktemp(prefix='v11u223_rec_', dir=os.environ.get('TMPDIR', '/tmp'))
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]
        rec = '|'.join(f[1:]); ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck, fl
(G, Gf), (P, Pf), (L, Lf) = [keyed(x) for x in sys.argv[1:4]]
lost = (P & G) - L; tow = (L & G) - P; fl = (Pf & Gf) - Lf; ft = (Lf & Gf) - Pf
print(f'chain_lost={sum(lost.values())} chain_toward={sum(tow.values())} flat_lost={sum(fl.values())} flat_toward={sum(ft.values())} dist {sum((Pf-Gf).values())}->{sum((Lf-Gf).values())}')
if len(sys.argv) > 4:
    for k, v in list(lost.items())[:10]: print('  CHAIN_LOST', v, k[1], '@', k[0][:200])
    for k, v in list(fl.items())[:10]: print('  FLAT_LOST', v, k)
