#!/usr/bin/env python3
"""rawaway.py <OFF wd> <ON wd> [jobs]: the flat raw census below the strict walk (r11u221).  For every probe / corpus /
downstream-lane database whose bytes differ between two gate sweeps: the uhdm-dump of golden, OFF and ON, cut at the
unreachable `\\_weaklyReferenced` tail, paths reduced to basenames, object ids dropped, as line multisets (this sees the
unnamed objects inside typespec copies that the strict walk canonicalises), and the vpiFullName multisets alone.
lost = golden-agreeing lines OFF had that ON lost; gained = the reverse.  A line multiset is order- and position-blind,
so a nonzero `lost` is a CANDIDATE to read object by object (generic lines such as `|vpiParent:` move with any
re-parenting); `fn_lost` (full names) is the sharper key.  Fenced corpus rows are skipped unread (fail-closed)."""
import os, re, sys, glob, hashlib, subprocess, collections, pickle
from concurrent.futures import ThreadPoolExecutor
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('rawaway.py: source drivers/env.sh first')
DUMP = os.environ['UHDM_DUMP']; OFF, ON = sys.argv[1:3]; J = int(sys.argv[3]) if len(sys.argv) > 3 else 2
sys.path.insert(0, os.environ['R221_ROOT'] + '/scripts')
import check_probe as cp
def fenced(p): return any(re.search(rf'\b{re.escape(f)}\b', p) for f in F)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except FileNotFoundError: return None
CD = '/tmp/r11u221_rawcache'; os.makedirs(CD, exist_ok=True)
def lines(u):
    m = f'{CD}/{md5(u)}.raw'
    if os.path.exists(m): return pickle.load(open(m, 'rb'))
    t = subprocess.run([DUMP, u], capture_output=True, text=True, errors='replace').stdout.splitlines()
    t = t[:next((i for i, l in enumerate(t) if l.startswith('\\_weaklyReferenced')), len(t))]
    c = collections.Counter(); fn = collections.Counter()
    for l in t:
        if 'Restored design' in l: continue
        l = re.sub(r'(, )?id:\d+', '', re.sub(r'/[^ ,:()]*/', '', l)).rstrip()
        c[l] += 1
        m2 = re.search(r'vpiFullName:(\S+)', l)
        if m2: fn[m2.group(1)] += 1
    pickle.dump((c, fn), open(m, 'wb')); return c, fn
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
        if m: jobs.append((re.sub(r'-[0-9a-f]+/?$', '', rel), m.group(1) + '/golden.uhdm', o, p))
for d in glob.glob(f'{ON}/downstream/*/'):
    rel = os.path.relpath(d, ON)
    if fenced(rel): continue
    p = d + 'slang.uhdm'; o = f'{OFF}/{rel}/slang.uhdm'
    g = glob.glob(d + 'surelog/*.uhdm') or glob.glob(d + 'surelog/**/*.uhdm', recursive=True)
    if os.path.exists(p) and md5(p) != md5(o) and g: jobs.append((rel.rstrip('/') + ' (lane; reference = the Surelog lane)', g[0], o, p))
def one(j):
    name, g, o, p = j
    if not (os.path.exists(g) and os.path.exists(o)): return f'{name} MISSING'
    (G, Gf), (Oc, Of), (Nc, Nf) = lines(g), lines(o), lines(p)
    lost = (Oc & G) - Nc; gain = (Nc & G) - Oc; fl = (Of & Gf) - Nf; fg = (Nf & Gf) - Of
    s = f'{name} lost={sum(lost.values())} gained={sum(gain.values())} fn_lost={sum(fl.values())} fn_gained={sum(fg.values())}'
    if fl: s += ' | FN_LOST ' + ' || '.join(k[:160] for k in list(fl)[:4])
    if lost: s += ' | LOST ' + ' || '.join(k.strip()[:120] for k in list(lost)[:4])
    return s
print(f'# {len(jobs)} databases differ between {OFF} and {ON}', flush=True)
with ThreadPoolExecutor(J) as ex:
    for r in ex.map(one, sorted(jobs)): print(r, flush=True)
