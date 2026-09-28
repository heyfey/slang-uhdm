#!/usr/bin/env python3
"""awayrows.py <OFF wd> <ON wd> [jobs]: map 12's away census on two gate sweeps (a landing or law switched off vs on):
every probe / corpus database whose bytes differ is walked by uhdm-strictcmp against itself (golden, off, on), each
record keyed by its ancestor chain (recaway2's key) and, as map 12 did, flat (depth dropped).  away = golden-agreeing
records the OFF database had and the ON database lost (a field a law moved AWAY from golden); toward = the reverse.
Fenced corpus rows are skipped unread (fail-closed on $FENCED)."""
import os, re, sys, glob, hashlib, subprocess, collections
from concurrent.futures import ThreadPoolExecutor
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awayrows.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']; OFF, ON = sys.argv[1:3]; J = int(sys.argv[3]) if len(sys.argv) > 3 else 3
sys.path.insert(0, os.environ['R204_ROOT'] + '/scripts')
import check_probe as cp
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
CD = '/tmp/r11u204_awaycache'; os.makedirs(CD, exist_ok=True)
def keyed(u):
    h = md5(u); m = f'{CD}/{h}.k'
    if os.path.exists(m):
        import pickle; return pickle.load(open(m, 'rb'))
    t = f'{CD}/{h}.{os.getpid()}.{threading_id()}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 3 or not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]
        rec = '|'.join(f[1:]); ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t)
    import pickle; pickle.dump((ck, fl), open(m, 'wb')); return ck, fl
import threading
def threading_id(): return threading.get_ident()
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
        m = re.search(r'golden cache hit (\S+)\)', open(d + 'cmds.txt').read()) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', open(d + 'cmds.txt').read())
        if not m: continue
        jobs.append((re.sub(r'-[0-9a-f]+/?$', '', rel), m.group(1) + '/golden.uhdm', o, p))
def one(j):
    name, g, o, p = j
    if not (os.path.exists(g) and os.path.exists(o)): return f'{name} MISSING'
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g), keyed(o), keyed(p)
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    s = f'{name} away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())}'
    if away: s += ' | ' + ' || '.join((k[1] + ' @ ' + k[0])[:260] for k in list(away)[:3])
    return s
print(f'# {len(jobs)} databases differ between {OFF} and {ON}', flush=True)
with ThreadPoolExecutor(J) as ex:
    for r in ex.map(one, sorted(jobs)): print(r, flush=True)
