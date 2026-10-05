#!/usr/bin/env python3
# v11u245: chain-keyed away census of case databases (the key of r11u245repro/drivers/awayrows.py: each record keyed by
# its ancestor chain, the raw full name in the record), on the variant comparator strictcmp_s1 (records dumped even
# when stage 1 fails).  chainaway.py <tagP> <tagL> [v]: every case-view under $S/g; lost = golden-agreeing records P had
# and L lost; toward = the reverse.  Case databases only; fail-closed on $FENCED.
import os, re, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('chainaway.py: source drivers/env.sh first')
SC = os.environ.get('SCMP', '/tmp/v11u245_bin/strictcmp_s1'); S = os.environ['S']
P, L = sys.argv[1:3]; V = len(sys.argv) > 3
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def keyed(u):
    t = f'{S}/chainaway.{os.getpid()}.rec'
    if os.path.exists(t): os.remove(t)
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True,
                   env=dict(os.environ, V245_SKIP_STAGE1='1'))
    ck = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        d = int(f[0]); st = st[:d]
        ck[(' < '.join(reversed(st)), '|'.join(f[1:]))] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck
tl = tt = 0
for w in sorted(glob.glob(f'{S}/g/*/*')):
    if fenced(w): continue
    g = (glob.glob(f'{w}/gold_*/golden.uhdm') or [None])[0]
    p, l = f'{w}/{P}.uhdm', f'{w}/{L}.uhdm'
    if not g or not os.path.getsize(g) or not os.path.exists(p) or not os.path.exists(l): continue
    G, Pk, Lk = keyed(g), keyed(p), keyed(l)
    lost = (G & Pk) - Lk; tow = (G & Lk) - Pk
    nl, nt = sum(lost.values()), sum(tow.values()); tl += nl; tt += nt
    print(f'{w[len(S)+3:]} lost={nl} toward={nt}')
    if V:
        for k, v in lost.items(): print('  LOST', v, k)
print(f'TOTAL lost={tl} toward={tt}')
