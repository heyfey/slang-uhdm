#!/usr/bin/env python3
"""awayall.py <OFF wd> <ON wd> [jobs]: the away-moved-record census of two gate sweeps (a law off vs on) in BOTH keys.
Every probe / corpus database whose bytes differ between the two sweeps is walked with its golden, each record keyed
FLAT (depth dropped: v11u202's away.py, the key r11u216's verifier used) and by its ANCESTOR CHAIN (map 13's
awayrows.py).  lost = golden-agreeing records OFF had and ON lost; toward = the reverse.  The comparator is the gate's
uhdm-strictcmp ($STRICT_CMP, canonical records) or, with RAW=1, map 13's variant ($B/strictcmp_x) whose 15th column is
the raw full name.  A flat-lost record with chain_lost 0 is a generic record the law removed from a chain golden does
not hold it at (FLATART, printed with its chains).  Fenced corpus rows are skipped unread (fail closed on $FENCED);
paths resolve from this checkout; the record cache lives under $S (default /tmp/r11u225_awaycache)."""
import os, re, sys, glob, hashlib, subprocess, collections, pickle, threading
from concurrent.futures import ThreadPoolExecutor
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awayall.py: source drivers/env.sh first')
RAW = os.environ.get('RAW') == '1'
SC = os.path.join(os.environ['B'], 'strictcmp_x') if RAW else os.environ['STRICT_CMP']
OFF, ON = sys.argv[1:3]; J = int(sys.argv[3]) if len(sys.argv) > 3 else 3
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
CD = os.path.join(os.environ.get('S', '/tmp/r11u225_awaycache'), 'raw' if RAW else 'can'); os.makedirs(CD, exist_ok=True)
def keyed(u):
    h = md5(u); m = f'{CD}/{h}.k'
    if os.path.exists(m): return pickle.load(open(m, 'rb'))
    t = f'{CD}/{h}.{os.getpid()}.{threading.get_ident()}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=7200)
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
    os.remove(t)
    pickle.dump((ck, fl), open(m, 'wb')); return ck, fl
jobs = []
for p in glob.glob(f'{ON}/probe/*.uhdm'):
    b = os.path.basename(p); o = f'{OFF}/probe/{b}'
    if md5(p) != md5(o):
        rel = b[:-5].replace('__', '/'); jobs.append((f'probe/{rel}', os.path.join(cp.cache_dir(rel), 'golden.uhdm'), o, p))
for c in ('surelog', 'uhdm2rtlil'):
    for d in glob.glob(f'{ON}/{c}/*/*/'):
        rel = os.path.relpath(d, ON)
        if fenced(rel): continue
        p = d + 'slang.uhdm'; o = f'{OFF}/{rel}/slang.uhdm'
        if not os.path.exists(p) or md5(p) == md5(o): continue
        txt = open(d + 'cmds.txt').read()
        m = re.search(r'golden cache hit (\S+)\)', txt) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', txt)
        if not m: continue
        jobs.append((re.sub(r'-[0-9a-f]+/?$', '', rel), m.group(1) + '/golden.uhdm', o, p))
def one(j):
    name, g, o, p = j
    if not (os.path.exists(g) and os.path.exists(o)): return (name, None)
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g), keyed(o), keyed(p)
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    s = f'{name} chain_lost={sum(away.values())} chain_toward={sum(tow.values())} flat_lost={sum(fa.values())} flat_toward={sum(ft.values())}'
    if away: s += '\n  CHAIN_LOST ' + '\n  CHAIN_LOST '.join((k[1] + ' @ ' + k[0])[:400] for k in list(away)[:5])
    # In-place pairing: a flat-lost record removed from a chain where golden holds fewer of it than OFF did, with a
    # record gained toward golden at the same chain (golden holds more of it than OFF did), is a record REPLACED by
    # golden's at its own position; flat_unpaired counts the flat-lost records no such replacement explains.
    unp = 0
    for r, v in fa.items():
        ctx = [(k[0], Ok[k], Nk[k], G.get(k, 0)) for k in set(Ok) | set(Nk) if k[1] == r and Ok[k] != Nk[k]]
        paired = 0
        for c, a, b, gg in ctx:
            if b < a and gg < a:
                rep = sum(min(Nk[k] - Ok[k], G.get(k, 0) - Ok[k]) for k in tow if k[0] == c)
                paired += min(a - b, a - max(gg, b), rep)
        unp += max(0, v - paired)
        s += f'\n  FLAT_LOST {v} (paired in place with a golden record at the same chain: {min(v, paired)}) {r}'
        for c, a, b, gg in ctx[:4]: s += f'\n     chain off={a} on={b} golden={gg} @ {c[:300]}'
    s = s.replace(f'flat_toward={sum(ft.values())}', f'flat_toward={sum(ft.values())} flat_unpaired={unp}', 1)
    return (name, (sum(away.values()), sum(tow.values()), sum(fa.values()), sum(ft.values()), unp), s)
print(f'# {len(jobs)} databases differ between {OFF} and {ON} ({"raw" if RAW else "canonical"} records)', flush=True)
tot = [0, 0, 0, 0, 0]
with ThreadPoolExecutor(J) as ex:
    for r in ex.map(one, sorted(jobs)):
        if r[1] is None: print(r[0], 'MISSING'); continue
        tot = [a + b for a, b in zip(tot, r[1])]; print(r[2], flush=True)
print(f'TOTAL chain_lost={tot[0]} chain_toward={tot[1]} flat_lost={tot[2]} flat_toward={tot[3]} flat_unpaired={tot[4]}')
