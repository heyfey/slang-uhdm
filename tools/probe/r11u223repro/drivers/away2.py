#!/usr/bin/env python3
"""away2.py <golden.uhdm> <off.uhdm> <on.uhdm> <scratch> [v]: the away census of one database pair in BOTH keys
over the gate comparator's own canonical records (uhdm-strictcmp --dump-a, $STRICT_CMP; RAW=1: map 13's variant $B/strictcmp_x with the raw full name): FLAT = the record without
its depth (v11u202's away.py, the key r11u216's verifier used), CHAIN = the record keyed by its ancestor chain
(type:name of every ancestor, map 13's awayrows.py).  lost = golden-agreeing records the OFF database had and the ON
one lost; toward = the reverse.  With `v`, every lost record is printed with its chain."""
import sys, os, subprocess, collections
RAW = os.environ.get('RAW') == '1'
SC = os.path.join(os.environ.get('B', ''), 'strictcmp_x') if RAW else os.environ.get('STRICT_CMP')
if not SC: sys.exit('away2.py: source drivers/env.sh first')
def recs(u, wd, tag):
    t = f'{wd}/{tag}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=7200)
    fl = collections.Counter(); ck = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if not f[0].isdigit(): continue
        if RAW:
            if len(f) < 15: continue
            raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        d = int(f[0]); st = st[:d]
        rec = '\t'.join(f[1:]); fl[rec] += 1; ck[(' < '.join(reversed(st)), rec)] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t)
    return fl, ck
g, o, n, wd = sys.argv[1:5]; os.makedirs(wd, exist_ok=True)
Gf, Gc = recs(g, wd, 'g'); Of, Oc = recs(o, wd, 'o'); Nf, Nc = recs(n, wd, 'n')
fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of; ca = (Oc & Gc) - Nc; ct = (Nc & Gc) - Oc
print(f'flat_lost={sum(fa.values())} flat_toward={sum(ft.values())} chain_lost={sum(ca.values())} chain_toward={sum(ct.values())}')
if len(sys.argv) > 5:
    for k, v in fa.items(): print('  FLAT_LOST', v, k)
    for k, v in ca.items(): print('  CHAIN_LOST', v, k[1], ' @ ', k[0][:400])
