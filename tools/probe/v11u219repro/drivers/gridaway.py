#!/usr/bin/env python3
"""gridaway.py <scratch g root> [RAW=1 env]: the away census of every case-view of the grid (case.sh's P.uhdm = pristine,
L.uhdm = law, golden.uhdm), records chain-keyed and flat (depth dropped), canonical (uhdm-strictcmp) or raw full names
($VB/strictcmp_x, RAW=1).  lost = golden-agreeing records P had and L lost; toward = the reverse.  With REV=1 the two
sides are swapped (the positive control).  Fence fail-closed."""
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('gridaway.py: source drivers/env.sh first')
RAW = os.environ.get('RAW') == '1'; REV = os.environ.get('REV') == '1'
SC = os.path.join(os.environ['VB'], 'strictcmp_x') if RAW else os.environ['STRICT_CMP']
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def keyed(u, t):
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if not f[0].isdigit(): continue
        if RAW:
            if len(f) < 15: continue
            raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        d = int(f[0]); st = st[:d]
        rec = '|'.join(f[1:]); ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck, fl
tot = collections.Counter()
for w in sorted(glob.glob(os.path.join(sys.argv[1], '**', 'L.uhdm'), recursive=True)):
    d = os.path.dirname(w)
    if fenced(d): print(d, 'FENCED refused'); continue
    g = glob.glob(d + '/gold_*/golden.uhdm'); p = d + '/P.uhdm'
    if not g or not os.path.exists(p): continue
    if open(p, 'rb').read() == open(w, 'rb').read(): continue
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g[0], d + '/.g.rec'), keyed(p, d + '/.p.rec'), keyed(w, d + '/.l.rec')
    if REV: Ok, Of, Nk, Nf = Nk, Nf, Ok, Of
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    r = (sum(away.values()), sum(tow.values()), sum(fa.values()), sum(ft.values()))
    tot.update(dict(zip(('chain_lost', 'chain_toward', 'flat_lost', 'flat_toward'), r)))
    print(re.sub(r'^.*/g/', '', d), 'chain_lost=%d chain_toward=%d flat_lost=%d flat_toward=%d' % r)
    for k in list(away)[:6]: print('   CHAIN_LOST', (k[1] + ' @ ' + k[0])[:300])
print('TOTAL', dict(tot))
