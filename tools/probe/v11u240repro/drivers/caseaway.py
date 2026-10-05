#!/usr/bin/env python3
# (v11u240) caseaway.py <S> <rel> <tagA> <tagB>: chain-keyed and flat away census of one case-view from case.sh's store
# ($S/g/<rel>/{gold_*/golden.uhdm,<tag>.uhdm}), records from the variant comparator ($SCX, raw full name column).
# away = golden-agreeing records tagA had and tagB lost; toward = the reverse. Fail-closed on $FENCED.
import os, sys, glob, subprocess, collections, re
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('caseaway.py: source drivers/env.sh first')
S, rel, ta, tb = sys.argv[1:5]
if any(re.search(rf'\b{re.escape(f)}\b', rel) for f in F): sys.exit('fenced')
SC = os.environ.get('SCX') or os.path.join(os.environ['B'], 'strictcmp_x')
w = f'{S}/g/{rel}'; g = glob.glob(f'{w}/gold_*/golden.uhdm')[0]
def keyed(u):
    t = f'{w}/.aw.{os.getpid()}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        d = int(f[0]); st = st[:d]
        rec = '|'.join(f[1:]); ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t); return ck, fl
(G, Gf), (A, Af), (Bk, Bf) = keyed(g), keyed(f'{w}/{ta}.uhdm'), keyed(f'{w}/{tb}.uhdm')
away = (A & G) - Bk; tow = (Bk & G) - A; fa = (Af & Gf) - Bf; ft = (Bf & Gf) - Af
print(f'{rel} {ta}->{tb} away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())} dist={sum((A-G).values())}->{sum((Bk-G).values())}')
if len(sys.argv) > 5:
    for k, v in list(away.items())[:40]: print('  AWAY', v, k[1], '@', k[0][:200])
    for k, v in list(tow.items())[:40]: print('  TOW ', v, k[1], '@', k[0][:200])
