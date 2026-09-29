#!/usr/bin/env python3
"""vaway.py <case-view dir> <off tag> <on tag>: chain-keyed and flat away census on uhdm-strictcmp record dumps
(<tag>.a.rec = golden, <tag>.b.rec = ours, written by vcase.sh).  away = golden-agreeing records the OFF database
had and the ON one lost; toward = the reverse.  Prints: away toward flat_away flat_toward."""
import sys, collections
def keyed(f):
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(f, errors='replace'):
        x = l.rstrip('\n').split('\t')
        if len(x) < 14 or not x[0].isdigit(): continue
        d = int(x[0]); st = st[:d]
        rec = '|'.join(x[1:14]); ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1
        st.append(f'{x[1]}:{x[2]}')
    return ck, fl
d, a, b = sys.argv[1:4]
G, Gf = keyed(f'{d}/{a}.a.rec'); O, Of = keyed(f'{d}/{a}.b.rec'); N, Nf = keyed(f'{d}/{b}.b.rec')
aw = (O & G) - N; tw = (N & G) - O; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
print(f'away={sum(aw.values())} toward={sum(tw.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())}')
for k in list(aw)[:3]: print('  AWAY', (k[1] + ' @ ' + k[0])[:300])
