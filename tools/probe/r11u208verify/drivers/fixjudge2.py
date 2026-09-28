#!/usr/bin/env python3
# (r11u208: copied from r11u204verify/drivers, paths renamed.)
"""fixjudge2.py <fixbound.txt>: every case-mode fixbound.sh reads MOVED is re-run with case.sh (tags law, fix;
GW=/tmp/r11u208_g for this directory's cases, /tmp/r11u208_ge for another pass's evidence cases) and judged against
its golden: the strict verdict per binary, and recaway2's chain-keyed records: away = golden-agreeing records law.bin
had that fix.bin lost, toward = golden-agreeing records fix.bin has that law.bin lacked, newbad / gonebad = records golden lacks that fix.bin adds / removes.  Fail-closed on $FENCED."""
import os, re, sys, subprocess, collections, pickle, glob
FEN = os.environ.get('FENCED', '').split()
if len(FEN) != 4: sys.exit('fixjudge2.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__)); R = os.environ['R208_ROOT']; SC = os.environ['STRICT_CMP']
def keyed(u):
    t = u + '.krec2'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    c = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 3 or not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]; c[(' < '.join(reversed(st)), '|'.join(f[1:]))] += 1; st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return c
tot = collections.Counter()
for l in open(sys.argv[1]):
    f = l.split()
    if 'MOVED' not in f: continue
    rel = f[0]; el = f[1] == 'el'; c = f'{R}/tools/probe/{rel}'
    if any(re.search(rf'\b{re.escape(n)}\b', c) for n in FEN): continue
    gw = '/tmp/r11u208_g' if '/r11u208verify/' in c else '/tmp/r11u208_ge'
    env = dict(os.environ, EL='1' if el else '0', GW=gw)
    out = {t: subprocess.run([f'{D}/case.sh', c, t, b], capture_output=True, text=True, env=env).stdout.strip()
           for t, b in (('law', os.environ['LAW']), ('fix', os.environ['FIX']))}
    rl = out['law'].split()[0]; w = f'{gw}/{rl}'
    g = glob.glob(f'{w}/gold_*/golden.uhdm')
    if not g: print(f'{rl} NOGOLD'); continue
    G, A, B = keyed(g[0]), keyed(f'{w}/law.uhdm'), keyed(f'{w}/fix.uhdm')
    away = (A & G) - B; tow = (B & G) - A; newbad = (B - G) - (A - G); gonebad = (A - G) - (B - G)
    sv = lambda t: re.search(r'strict=(\S+)', out[t]).group(1) if 'strict=' in out[t] else out[t].split()[2]
    v = 'AWAY' if away and not tow else 'MIXED' if away else 'TOWARD' if tow else 'NEWBAD' if newbad and not gonebad else 'BYTES-ONLY'
    tot[v] += 1
    print(f"{rl} {v} away={sum(away.values())} toward={sum(tow.values())} newbad={sum(newbad.values())} gonebad={sum(gonebad.values())} | law {sv('law')} | fix {sv('fix')}" +
          (' | away: ' + ' || '.join((k[1] + ' @ ' + k[0])[:200] for k in list(away)[:2]) if away else ''), flush=True)
print('TALLY', dict(tot))
