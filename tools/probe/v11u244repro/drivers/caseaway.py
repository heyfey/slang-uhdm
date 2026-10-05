#!/usr/bin/env python3
# (v11u244) caseaway.py <casegridroot> <tagOFF> <tagON> <casepath>...: map 13's chain-keyed away census (the record
# keying of tools/probe/r11u244repro/drivers/awayrows.py: strictcmp_x records, raw full name, ancestor chain) on one
# grid case-view's golden, <tagOFF>.uhdm and <tagON>.uhdm (case.sh layout under $S/g). Each database is dumped by
# comparing it with itself, so a stage-1 case is walked too. away = golden-agreeing records OFF had and ON lost.
# Fail-closed on $FENCED; a fenced path is refused.
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('caseaway.py: source drivers/env.sh first')
SC = os.environ.get('SCX') or os.path.join(os.environ['B'], 'strictcmp_x')
def keyed(u, t):
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
root, toff, ton = sys.argv[1:4]; verbose = os.environ.get('V')
for c in sys.argv[4:]:
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', c) for f in F): sys.exit('fenced path refused')
    d = os.path.join(root, c); gs = glob.glob(d + '/gold_*/golden.uhdm')
    if not gs or not os.path.exists(f'{d}/{toff}.uhdm') or not os.path.exists(f'{d}/{ton}.uhdm'): print(c, 'MISSING'); continue
    (G, Gf), (O, Of), (N, Nf) = keyed(gs[0], d + '/.ka'), keyed(f'{d}/{toff}.uhdm', d + '/.kb'), keyed(f'{d}/{ton}.uhdm', d + '/.kc')
    away = (O & G) - N; tow = (N & G) - O; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    print(f'{c} away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())} dist_off={sum((Of-Gf).values())} dist_on={sum((Nf-Gf).values())}')
    if verbose:
        for k in away: print('   AWAY', k[1], '@', k[0][:200])
        for k in (Nf - Gf) - (Of - Gf): print('   NEWWRONG', k)
        for k in fa: print('   FLATAWAY', fa[k], k)
