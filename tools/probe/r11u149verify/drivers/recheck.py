#!/usr/bin/env python3
# recheck.py <refTag> <newTag> <rows.tsv: corp name mode>  -> per row, the strict-record check (worse.py's rule):
# NEW = a record the reference walk matched (before its own structural divergence) differs under new;
# IMPROVE = the new differing set is a subset of the reference's; UNMASK = new records only past the reference's divergence.
import sys, os, re, glob, subprocess, hashlib
FENCED = set(os.environ.get('FENCED', '').split())  # slang-fenced test names from the environment, never spelled here
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, '/tmp/wt_r11u149/scripts')
SC = '/tmp/r11u149_bin/uhdm-strictcmp'
STRUCT = ('type', 'depth', 'count', 'name')
ref, new, rows = sys.argv[1], sys.argv[2], sys.argv[3]
OUT = f'/tmp/r11u149_rec'; os.makedirs(OUT, exist_ok=True)
def recs(g, o, tag):
    key = hashlib.md5((g + o).encode()).hexdigest()[:10]
    f = f'{OUT}/{tag}_{key}.txt'
    if not os.path.exists(f):
        r = subprocess.run([SC, '--max', '1000000', g, o], capture_output=True, text=True, timeout=3600)
        open(f, 'w').write(r.stdout + r.stderr)
    t = open(f).read(); lines = t.split('\n'); d = {}
    for i, ln in enumerate(lines):
        m = re.match(r'#(\d+) (\w+)', ln)
        if m: d[int(m.group(1))] = (m.group(2), lines[i+1].strip(), lines[i+2].strip() if i+2 < len(lines) else '')
    return d, '(walk diverged)' in t, [l for l in lines if l.strip()][-1] if t.strip() else ''
def paths(tag, corp, name, mode):
    W = f'/tmp/r11u149_w{tag}'
    if corp == 'probe':
        import check_probe as cp
        rel = name
        g = cp.cache_dir(rel); gg = sorted(glob.glob(g + '/*.uhdm'))
        return (gg[0] if gg else None), f'{W}/probe/' + rel.replace('/', '__') + '.uhdm'
    m = {'d': 'default', 't': 'testflags'}[mode]
    d = glob.glob(f'{W}/{corp}/{m}/{name}-*')
    d = [x for x in d if re.fullmatch(re.escape(name) + r'-[0-9a-f]{8}', os.path.basename(x))][0]
    gdir = re.search(r'golden cache hit ([^)]*)', open(d + '/cmds.txt').read()).group(1)
    gg = sorted(glob.glob(gdir + '/*.uhdm'))
    return gg[0], d + '/slang.uhdm'
def one(line):
    corp, name, mode = line.split('\t')[:3]
    try:
        g, a = paths(ref, corp, name, mode); _, b = paths(new, corp, name, mode)
        da, va, la = recs(g, a, ref); db, vb, lb = recs(g, b, new)
    except Exception as e:
        return f'ERROR\t{corp}\t{name}\t{mode}\t{e}'
    if 'STRICT_EQUAL' in lb: v = 'EQUAL'
    else:
        pdiv = min([i for i, (f, _, _) in da.items() if f in STRUCT], default=10**12) if va else 10**12
        nw = [i for i in db if i < pdiv and i not in da]
        ch = [i for i in db if i < pdiv and i in da and db[i][2] != da[i][2]]
        if nw: v = f'NEW{nw[:4]}'
        elif set(db) <= set(da): v = 'IMPROVE' if (len(db) < len(da) or ch) else 'SAME-RECS'
        else:
            v = f'UNMASK(refdiv=#{pdiv})'
        if ch and not nw: v += f'(value-changed={len(ch)})'
    fa = min(da) if da else None; fb = min(db) if db else None
    ndiv = min([i for i, (f, _, _) in db.items() if f in STRUCT], default=None) if vb else None
    rdiv = min([i for i, (f, _, _) in da.items() if f in STRUCT], default=None) if va else None
    if ndiv is not None and rdiv is not None and ndiv < rdiv: v = 'EARLIER-DIVERGENCE:' + v
    return f'{v}\t{corp}\t{name}\t{mode}\t{ref}: n={len(da)} div={va}@{rdiv} first=#{fa}\t{new}: n={len(db)} div={vb}@{ndiv} first=#{fb}\t{la} -> {lb}'
lines = [l.rstrip('\n') for l in open(rows) if l.strip()]
lines = [l for l in lines if l.split('\t')[1] not in FENCED]
with ThreadPoolExecutor(int(os.environ.get('J', '3'))) as ex:
    for r in ex.map(one, lines): print(r, flush=True)
