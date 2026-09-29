#!/usr/bin/env python3
"""r11u229: caseaway.py <case store dir>... : the away-moved-record census of every state drivers/grid.py wrote in a
case-view store ($GW/<family>/<case>[_el]/<tag>.uhdm) against the store's golden (gold_*/golden.uhdm), in BOTH keys
(chain-keyed: the record with its ancestor chain; flat: the record alone), with the record keying of
r11u225repro/drivers/awayall.py and v11u225repro/drivers/awaycase.py (the gate's uhdm-strictcmp self-walk
--dump-a, so stage-1 pairs are walked too).  For each state tag <t> other than `on` whose bytes differ from `on`:
lost = golden-agreeing records <t> (the law off) had and `on` lost; toward = the reverse.  Prints one line per
(case-view, state) that moves, with the first chain-lost records.  RESCORE-safe: reads only.  A positive control:
REVERSE=1 swaps the two sides (every toward reads lost).  Fail-closed on $FENCED."""
import os, re, sys, glob, hashlib, subprocess, collections, pickle
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('caseaway.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']
if not os.access(SC, os.X_OK): sys.exit('caseaway.py: STRICT_CMP not executable')
CD = os.environ.get('AWAYCACHE', '/tmp/r11u229_awaycache'); os.makedirs(CD, exist_ok=True)
REV = os.environ.get('REVERSE') == '1'
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
tot = collections.Counter()
for d in sys.argv[1:]:
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in F): print('FENCED-SKIP', d); continue
    g = glob.glob(d + '/gold_*/golden.uhdm'); on = f'{d}/on.uhdm'
    if not g or not os.path.exists(on): continue
    G, Gf = keyed(g[0]); N, Nf = keyed(on); hon = md5(on)
    for o in sorted(glob.glob(d + '/*.uhdm')):
        t = os.path.basename(o)[:-5]
        if t in ('on', 'tr', 'q') or md5(o) == hon: continue
        O, Of = keyed(o)
        A, Af, B, Bf = (N, Nf, O, Of) if REV else (O, Of, N, Nf)
        cl = (A & G) - B; ct = (B & G) - A; fl = (Af & Gf) - Bf; ft = (Bf & Gf) - Af
        r = (sum(cl.values()), sum(ct.values()), sum(fl.values()), sum(ft.values()))
        tot[t.split('_')[0] + '_lost'] += r[0]; tot['chain_lost'] += r[0]; tot['chain_toward'] += r[1]
        tot['flat_lost'] += r[2]; tot['flat_toward'] += r[3]
        print(f'{d.split("/r11u229_g/")[-1]} {t} chain_lost={r[0]} chain_toward={r[1]} flat_lost={r[2]} flat_toward={r[3]}')
        for k in list(cl)[:3]: print('  CHAIN_LOST', (k[1] + ' @ ' + k[0])[:300])
print('TOTAL', dict(tot))
