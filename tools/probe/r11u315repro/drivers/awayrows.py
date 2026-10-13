#!/usr/bin/env python3
# (r11u315: copied from r11u313repro/drivers)
# (r11u313: copied from v11u311repro/drivers)
# (v11u311: copied from r11u311repro/drivers)
# (r11u311: copied from r11u309repro/drivers)
# (r11u309: copied from r11u307repro/drivers)
# (r11u307: copied from r11u305repro/drivers)
# (r11u305: copied from r11u303repro/drivers)
# (r11u303: copied from r11u301repro/drivers)
# (r11u299: copied from r11u297repro/drivers)
# (r11u297: copied from r11u295repro/drivers)
# (r11u295: copied from r11u293repro/drivers)
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
# (r11u287: copied from r11u285repro/drivers)
# (r11u285: copied from r11u283repro/drivers)
# (r11u283: copied from r11u281repro/drivers)
# (r11u279: copied from r11u277repro/drivers)
# (r11u277: copied from r11u275repro/drivers)
# (r11u275: copied from r11u273repro/drivers)
# (r11u273: copied from r11u271repro/drivers)
# (r11u271: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u252repro/drivers)
# (r11u250: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247: copied from r11u244repro/drivers)
# (r11u244: copied from r11u242repro/drivers)
# (r11u238 (from r11u236repro): copied from r11u232repro/drivers)
"""(r11u244repro: copied from r11u218dec/drivers/awayrows.py) awayrows.py <OFF wd> <ON wd> [jobs]: map 13's away census (tools/probe/r11u211map/drivers/awayrows.py) on two gate
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
OFF, ON = sys.argv[1:3]; J = int(sys.argv[3]) if len(sys.argv) > 3 else 3
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
    if not (os.path.exists(g) and os.path.exists(o)): return f'{name} MISSING'
    (G, Gf), (Ok, Of), (Nk, Nf) = keyed(g), keyed(o), keyed(p)
    away = (Ok & G) - Nk; tow = (Nk & G) - Ok; fa = (Of & Gf) - Nf; ft = (Nf & Gf) - Of
    s = f'{name} away={sum(away.values())} toward={sum(tow.values())} flat_away={sum(fa.values())} flat_toward={sum(ft.values())}'
    if away: s += ' | ' + ' || '.join((k[1] + ' @ ' + k[0])[:300] for k in list(away)[:3])
    return s
print(f'# {len(jobs)} databases differ between {OFF} and {ON}', flush=True)
with ThreadPoolExecutor(J) as ex:
    for r in ex.map(one, sorted(jobs)): print(r, flush=True)
