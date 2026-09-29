#!/usr/bin/env python3
"""v11u228 (copied from r11u228repro): flatexplain.py <OFF tag> <ON tag> <case store dir>...: for every flat-lost record of awaycase.py (a record
golden and OFF share that ON lacks, depth dropped), list the ancestor chains OFF held it at and ON no longer does, and
whether golden holds the record at any of those chains (EXPLAINED = golden holds it at none of them: a removal at a
chain golden does not have, toward golden in place)."""
import os, sys, glob, subprocess, collections
SC = os.environ['STRICT_CMP']
def keyed(u):
    t = u + '.fx'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]; rec = '|'.join(f[1:])
        ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1; st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck, fl
OFF, ON = sys.argv[1:3]; n = ex = 0
for d in sys.argv[3:]:
    g = glob.glob(d + '/gold_*/golden.uhdm')
    if not g: continue
    (G, Gf), (O, Of), (N, Nf) = keyed(g[0]), keyed(f'{d}/{OFF}.uhdm'), keyed(f'{d}/{ON}.uhdm')
    for r, c in ((Of & Gf) - Nf).items():
        removed = [k for k in (O - N) if k[1] == r]
        held = [k for k in removed if G[k] >= O[k]]
        n += c; ok = not held; ex += c if ok else 0
        print(('EXPLAINED ' if ok else 'UNEXPLAINED ') + d.split('/g/')[-1], 'x%d' % c, r[:80],
              '| removed at:', '; '.join(k[0][:90] for k in removed[:2]))
print(f'TOTAL flat_lost={n} explained={ex} unexplained={n - ex}')
