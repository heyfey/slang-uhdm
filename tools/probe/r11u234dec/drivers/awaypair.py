#!/usr/bin/env python3
"""r11u234 (copied from r11u233verify/drivers/awaypair.py; the cache dir from $AWAYCACHE, required): awaypair.py <A tag> <B tag> <case store dir>...: the away-moved-record census of B against A (drivers/caseaway.py's
record keying: the gate's uhdm-strictcmp self-walk records, chain-keyed with the ancestor chain and flat), per case-view
store: lost = golden-agreeing records A had and B lost; toward = the reverse.  REVERSE=1 swaps A and B (positive control).
Reads only the stores (case outputs of drivers/case.sh); fail-closed on $FENCED."""
import os, re, sys, glob, hashlib, subprocess, collections, pickle
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awaypair.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']
if not os.access(SC, os.X_OK): sys.exit('awaypair.py: STRICT_CMP not executable')
CD = os.environ.get('AWAYCACHE') or sys.exit('awaypair.py: export AWAYCACHE'); os.makedirs(CD, exist_ok=True)
def md5(p): return hashlib.md5(open(p, 'rb').read()).hexdigest()
def keyed(u):
    h = md5(u); m = f'{CD}/{h}.k'
    if os.path.exists(m): return pickle.load(open(m, 'rb'))
    t = f'{CD}/{h}.{os.getpid()}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]; rec = '|'.join(f[1:])
        ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1; st.append(f'{f[1]}:{f[2]}')
    os.remove(t); pickle.dump((ck, fl), open(m, 'wb')); return ck, fl
A, B = sys.argv[1:3]
if os.environ.get('REVERSE') == '1': A, B = B, A
tot = [0, 0, 0, 0]; moved = 0; same = 0
for d in sys.argv[3:]:
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in F): print('FENCED-SKIP', d); continue
    g = glob.glob(d + '/gold_*/golden.uhdm'); a = f'{d}/{A}.uhdm'; b = f'{d}/{B}.uhdm'
    if not g or not os.path.exists(a) or not os.path.exists(b): continue
    if md5(a) == md5(b): same += 1; continue
    moved += 1
    G, Gf = keyed(g[0]); Ak, Af = keyed(a); Bk, Bf = keyed(b)
    cl = (Ak & G) - Bk; ct = (Bk & G) - Ak; fl = (Af & Gf) - Bf; ft = (Bf & Gf) - Af
    r = [sum(cl.values()), sum(ct.values()), sum(fl.values()), sum(ft.values())]
    tot = [x + y for x, y in zip(tot, r)]
    print(f'{os.path.relpath(d, os.environ.get("GW", "/"))} {A}->{B} chain_lost={r[0]} chain_toward={r[1]} flat_lost={r[2]} flat_toward={r[3]}')
    for k in list(cl)[:3]: print('  CHAIN_LOST', (k[1] + ' @ ' + k[0])[:300])
print(f'TOTAL {A}->{B} moved={moved} same={same} chain_lost={tot[0]} chain_toward={tot[1]} flat_lost={tot[2]} flat_toward={tot[3]}')
