#!/usr/bin/env python3
# (r11u238 (from r11u236repro): copied from r11u232repro/drivers)
"""(v11u238: awaycase.py <case-scratch-root> <offtag> <ontag> [jobs]: the same away census on every case-view directory
of drivers/case.sh's store holding both tags' databases and a golden, golden.uhdm vs <offtag>.uhdm vs <ontag>.uhdm.)
(r11u238repro: copied from r11u218dec/drivers/awayrows.py) awayrows.py <OFF wd> <ON wd> [jobs]: map 13's away census (tools/probe/r11u211map/drivers/awayrows.py) on two gate
sweeps (a law switched off vs on), with one change: the records are the VARIANT comparator's (drivers' strictcmp_x,
$SCX) and the full-name field is the RAW full name (the 15th column), so a full name a law moves inside a
canonicalised typespec copy (which the tool's own record prints as `<in>...` on both sides) is seen.  Every probe /
corpus database whose bytes differ is walked against itself (golden, off, on), each record keyed by its ancestor
chain and flat (depth dropped).  away = golden-agreeing records the OFF database had and the ON one lost; toward =
the reverse.  Fenced corpus rows are skipped unread (fail-closed on $FENCED); paths resolve from this checkout;
the record cache lives under $S/awaycache."""
import os, re, sys, glob, hashlib, subprocess, collections, pickle, threading
from concurrent.futures import ThreadPoolExecutor
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('awayrows.py: source drivers/env.sh first')
SC = os.environ.get('SCX') or os.path.join(os.environ['B'], 'strictcmp_x')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import check_probe as cp
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
CD = os.path.join(os.environ['S'], 'awaycache'); os.makedirs(CD, exist_ok=True)
def keyed(u):
    h = md5(u); m = f'{CD}/{h}.k'
    if os.path.exists(m): return pickle.load(open(m, 'rb'))
    t = f'{CD}/{h}.{os.getpid()}.{threading.get_ident()}.rec'
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); fl = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 15 or not f[0].isdigit(): continue
        raw = f[14].split('\x1f')[0]
        f = f[:14]; f[4] = raw  # the raw full name
        d = int(f[0]); st = st[:d]
        rec = '|'.join(f[1:]); ck[(' < '.join(reversed(st)), rec)] += 1; fl[rec] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t)
    pickle.dump((ck, fl), open(m, 'wb')); return ck, fl
ROOT, OFFT, ONT = sys.argv[1:4]; J = int(sys.argv[4]) if len(sys.argv) > 4 else 3
jobs = []
for d, _, fs in os.walk(ROOT):
    if fenced(d): continue
    if f'{OFFT}.uhdm' in fs and f'{ONT}.uhdm' in fs:
        g = glob.glob(f'{d}/gold_*/golden.uhdm')
        if g and md5(f'{d}/{OFFT}.uhdm') != md5(f'{d}/{ONT}.uhdm'):
            jobs.append((os.path.relpath(d, ROOT), g[0], f'{d}/{OFFT}.uhdm', f'{d}/{ONT}.uhdm'))
def one(j):
    name, g, o, p = j
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g), keyed(o), keyed(p)
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    s = f'{name} away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())}'
    if away: s += ' | ' + ' || '.join((k[1] + ' @ ' + k[0])[:300] for k in list(away)[:3])
    return s
print(f'# {len(jobs)} case-views differ between {OFFT} and {ONT}', flush=True)
with ThreadPoolExecutor(J) as ex:
    for r in ex.map(one, sorted(jobs)): print(r, flush=True)
