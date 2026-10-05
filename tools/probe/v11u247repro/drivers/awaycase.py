#!/usr/bin/env python3
# (v11u247) awaycase.py <case-store-dir>... : the chain-keyed away census (awayrows.py's keyed()) on case.sh's store:
# for each <store>/<case>[_el] dir holding gold_*/golden.uhdm, pristine.uhdm and law.uhdm (or the tags OFFTAG/ONTAG),
# away = golden-agreeing records pristine had and law lost; toward = the reverse; flat the same with depth chain dropped.
# Fail-closed on $FENCED; a path holding a fenced name is refused.
import os, re, sys, glob, hashlib, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awaycase.py: source drivers/env.sh first')
SC = os.environ.get('SCX') or os.path.join(os.environ['B'], 'strictcmp_x')
OFFT = os.environ.get('OFFTAG', 'pristine'); ONT = os.environ.get('ONTAG', 'law')
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def keyed(u):
    t = u + '.kx.rec'
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
md5 = lambda p: hashlib.md5(open(p, 'rb').read()).hexdigest()
for d in sys.argv[1:]:
    if fenced(d): print(d, 'FENCED-REFUSED'); continue
    g = glob.glob(d + '/gold_*/golden.uhdm'); o = f'{d}/{OFFT}.uhdm'; n = f'{d}/{ONT}.uhdm'
    if not g or not os.path.exists(o) or not os.path.exists(n): print(d, 'MISSING'); continue
    if md5(o) == md5(n): continue
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g[0]), keyed(o), keyed(n)
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    s = f'{d.split("/g/")[-1]} away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())}'
    if away: s += ' | ' + ' || '.join((k[1] + ' @ ' + k[0])[:300] for k in list(away)[:3])
    print(s, flush=True)
