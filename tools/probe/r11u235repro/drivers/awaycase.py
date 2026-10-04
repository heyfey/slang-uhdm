#!/usr/bin/env python3
"""r11u235 (copied from r11u231repro, before it r11u228repro, itself from v11u225repro): awaycase.py <OFF tag> <ON tag> <case store dir>...: the away-moved-record census of drivers/case.sh outputs
(<store>/<tag>.uhdm against <store>/gold_*/golden.uhdm), chain-keyed and flat, with the record keying of
r11u225repro/drivers/awayall.py (the gate's uhdm-strictcmp self-walk, so stage-1 pairs are walked too).
lost = golden-agreeing records OFF had and ON lost; toward = the reverse."""
import os, sys, glob, subprocess, collections
SC = os.environ['STRICT_CMP']
if not os.access(SC, os.X_OK): sys.exit('awaycase.py: STRICT_CMP not executable')
def keyed(u):
    t = u + '.selfrec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]; rec = '|'.join(f[1:])
        ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1; st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck, fl
OFF, ON = sys.argv[1:3]; tot = [0, 0, 0, 0]
for d in sys.argv[3:]:
    g = glob.glob(d + '/gold_*/golden.uhdm'); o = f'{d}/{OFF}.uhdm'; n = f'{d}/{ON}.uhdm'
    if not g or not os.path.exists(o) or not os.path.exists(n): print(d, 'MISSING'); continue
    if open(o, 'rb').read() == open(n, 'rb').read(): continue
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g[0]), keyed(o), keyed(n)
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    r = [sum(away.values()), sum(tow.values()), sum(fa.values()), sum(ft.values())]
    tot = [a + b for a, b in zip(tot, r)]
    print(f'{d.split("/g/")[-1]} chain_lost={r[0]} chain_toward={r[1]} flat_lost={r[2]} flat_toward={r[3]}')
    for k in list(away)[:4]: print('  CHAIN_LOST', (k[1] + ' @ ' + k[0])[:300])
print(f'TOTAL chain_lost={tot[0]} chain_toward={tot[1]} flat_lost={tot[2]} flat_toward={tot[3]}')
