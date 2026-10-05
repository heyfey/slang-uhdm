#!/usr/bin/env python3
"""v11u242: caseaway.py <case store $S/g> [tagA] [tagB]: the chain-keyed away census (r11u242repro/drivers/awayrows.py's
keying, strictcmp_x records, raw full names) on every case-view of the grid store: golden vs <tagA>.uhdm (default
pristine) vs <tagB>.uhdm (default law).  away = golden-agreeing records A had and B lost; toward = the reverse.
Only case-views whose two databases differ are walked.  Fail-closed on $FENCED; a path holding a fenced name is refused."""
import os, re, sys, glob, hashlib, subprocess, collections
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('caseaway.py: source drivers/env.sh first')
SC = os.environ.get('SCX') or os.path.join(os.environ['B'], 'strictcmp_x')
if not os.access(SC, os.X_OK): sys.exit('caseaway.py: strictcmp_x not executable')
root = sys.argv[1]; ta = sys.argv[2] if len(sys.argv) > 2 else 'pristine'; tb = sys.argv[3] if len(sys.argv) > 3 else 'law'
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def md5(p): return hashlib.md5(open(p, 'rb').read()).hexdigest()
def keyed(u):
    t = f'/tmp/v11u242_ca.{os.getpid()}.rec'
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
tot = collections.Counter()
for d in sorted(glob.glob(f'{root}/**/{ta}.uhdm', recursive=True)):
    w = os.path.dirname(d)
    if fenced(w): sys.exit('caseaway.py: fenced path refused')
    b = f'{w}/{tb}.uhdm'; g = glob.glob(f'{w}/gold_*/golden.uhdm')
    if not g or not os.path.exists(b): continue
    if md5(d) == md5(b): continue
    if os.path.exists(f'{w}/{ta}.cmp') and os.path.getsize(f'{w}/{ta}.cmp') > 0: tag = 'stage1'
    else: tag = 'judge-equal'
    (G, Gf), (A, Af), (N, Nf) = keyed(g[0]), keyed(d), keyed(b)
    away = (A & G) - N; tow = (N & G) - A; fa = (Af & Gf) - Nf; ft = (Nf & Gf) - Af
    s = f'{os.path.relpath(w, root)} [{tag}] away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())}'
    if away: s += ' | ' + ' || '.join((k[1] + ' @ ' + k[0])[:300] for k in list(away)[:3])
    print(s, flush=True)
    tot[tag + '_away'] += sum(away.values()); tot[tag + '_toward'] += sum(tow.values())
print('# TOTAL', dict(tot))
