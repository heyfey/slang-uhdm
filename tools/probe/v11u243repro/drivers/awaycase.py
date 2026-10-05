#!/usr/bin/env python3
"""awaycase.py <offTag> <onTag> [case-view dirs...]: map 12's away census on the grid's case-views (case.sh outputs
under $S/g), records from the VARIANT comparator ($B/strictcmp_x, raw full names, as drivers/awayrows.py) dumping
each database against itself, so stage-1 case-views are censused too.  Chain key = record + ancestor (type:name)
chain; flat key = record alone.  away = golden-agreeing records OFF had and ON lost; toward = the reverse.
Fail-closed on $FENCED; reads only grid outputs."""
import os, sys, glob, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awaycase.py: source drivers/env.sh first')
SC = os.path.join(os.environ['B'], 'strictcmp_x')
off, on = sys.argv[1:3]
dirs = sys.argv[3:] or sorted(d for d in glob.glob(os.path.join(os.environ['S'], 'g', '*', '*')) if os.path.isdir(d))
def keyed(u):
    t = u + '.selfrec'
    if not os.path.exists(t):
        subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=600)
    ck, fl, st = collections.Counter(), collections.Counter(), []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]; f = f[:14]; f[4] = raw
        d = int(f[0]); st = st[:d]; rec = '|'.join(f[1:])
        ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1; st.append(f'{f[1]}:{f[2]}')
    return ck, fl
tot = collections.Counter()
for d in dirs:
    if any(x in d for x in F): sys.exit('fenced path refused')
    g = glob.glob(os.path.join(d, 'gold_*', 'golden.uhdm'))
    o, n = os.path.join(d, off + '.uhdm'), os.path.join(d, on + '.uhdm')
    if not g or not os.path.exists(o) or not os.path.exists(n): continue
    if open(o, 'rb').read() == open(n, 'rb').read(): continue
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g[0]), keyed(o), keyed(n)
    a = sum(((Ok & G) - Nk).values()); t = sum(((Nk & G) - Ok).values())
    fa = sum(((Of & Gf) - Nf).values()); ft = sum(((Nf & Gf) - Of).values())
    tot.update(dict(n=1, away=a, toward=t, flat_away=fa, flat_toward=ft))
    print(f'{os.path.relpath(d, os.path.join(os.environ["S"], "g"))} away={a} toward={t} flat_away={fa} flat_toward={ft}')
print('TOTAL', dict(tot))
