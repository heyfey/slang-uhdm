#!/usr/bin/env python3
"""Run uhdm-strictcmp variants on every (golden, ours) pair of pairs.tsv and write one csv row per pair:
corpus,test,mode,<tag>... with the sweep's strict cell (equal | differ:<field>(<objects>) | stage1 | overflow)
plus <tag>_s (wall seconds) and <tag>_n (records per side, from the 'STRICT_EQUAL N objects' line or the
dump when asked).
usage: run_modes.py <pairs.tsv> <out.csv> <jobs> <tag>=<binary>[,arg,arg...] ...
Env FILTER=<regex on corpus/mode/test>, ROWS=<file of corpus,test,mode lines to keep>."""
import concurrent.futures, csv, os, re, subprocess, sys, time

pairs, out, jobs = sys.argv[1], sys.argv[2], int(sys.argv[3])
variants = []
for v in sys.argv[4:]:
    tag, rest = v.split('=', 1)
    parts = rest.split(',')
    variants.append((tag, parts[0], parts[1:]))
filt = os.environ.get('FILTER')
keep = None
if os.environ.get('ROWS'):
    keep = set(tuple(l.strip().split(',')[:3]) for l in open(os.environ['ROWS']) if l.strip())


def cell(rc, so):
    if rc == 0:
        return 'equal'
    if rc == 1:
        return 'stage1'
    if 'canon overflow' in so:
        return 'overflow'
    f = n = ''
    for l in so.splitlines():
        if l.startswith('STRICT_NOTEQUAL '):
            f = l.split(' ', 1)[1].strip()
        if 'objects_differing=' in l:
            n = l.split('objects_differing=')[1].split()[0]
    return f'differ:{f}({n})' if n else f'differ:{f}:rc{rc}'


def one(row):
    c, m, t, g, o = row[:5]
    res = {'corpus': c, 'test': t, 'mode': m}
    for tag, b, args in variants:
        if g == '-' or o == '-':
            res[tag] = 'unresolved'; continue
        t0 = time.time()
        try:
            r = subprocess.run([b, '--max', '0'] + args + [g, o], capture_output=True, text=True, timeout=1800)
            res[tag] = cell(r.returncode, r.stdout)
            mm = re.search(r'STRICT_EQUAL (\d+) objects', r.stdout)
            res[tag + '_n'] = mm.group(1) if mm else ''
        except subprocess.TimeoutExpired:
            res[tag] = 'timeout'; res[tag + '_n'] = ''
        res[tag + '_s'] = f'{time.time() - t0:.2f}'
    return res


rows = []
for l in open(pairs):
    f = l.rstrip('\n').split('\t')
    k = '/'.join([f[0], f[1], f[2]])
    if filt and not re.search(filt, k):
        continue
    if keep is not None and (f[0], f[2], f[1]) not in keep:
        continue
    rows.append(f)
cols = ['corpus', 'test', 'mode'] + [x for tag, _, _ in variants for x in (tag, tag + '_n', tag + '_s')]
with open(out, 'w', newline='') as fo:
    w = csv.DictWriter(fo, cols)
    w.writeheader()
    with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
        for res in ex.map(one, rows):
            w.writerow(res)
            fo.flush()
print(f'{len(rows)} pairs -> {out}')
