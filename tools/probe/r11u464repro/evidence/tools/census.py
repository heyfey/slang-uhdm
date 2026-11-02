#!/usr/bin/env python3
"""Traced census of a law binary over the surelog and uhdm2rtlil corpora.

census.py <law binary> <fenced-list file> <out dir> <control dir> [jobs]
Runs only the slang-uhdm side of every non-fenced row-mode (default and
testflags, the arguments verify_golden.py builds) with R11U464_TRACE set,
then compares the database bytes with the control sweep's database of the
same row-mode.  Prints one line per row-mode that fired or moved.
The fence filter runs on the row names before any file of a row is read.
"""
import hashlib, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../../../../scripts'))
import verify_golden as vg

law, fenced_f, out, ctl = sys.argv[1:5]
jobs = int(sys.argv[5]) if len(sys.argv) > 5 else 3
fenced = set(l.strip() for l in open(fenced_f) if l.strip())
tasks = []
flt = os.environ.get("CENSUS_FILTER")
for corpus, disc in (('surelog', vg.discover_surelog), ('uhdm2rtlil', vg.discover_uhdm2rtlil)):
    rows = disc(None)
    for name, (dirpath, parts) in rows.items():
        if any(f in name for f in fenced) or name in vg.DEFERRED_TESTS or (flt and not __import__("re").search(flt, name)):
            continue
        sources, _ = vg.split_sources(parts)
        loc, sl_only = vg.location_args(parts)
        su_mode = ['--sverilog'] if '-sverilog' in sl_only else []
        su_def = su_mode + [vg.LOCATION_RENAME.get(a, a) for a in loc] + list(sources) + ['--single-unit']
        tasks.append((corpus, 'default', name, dirpath, su_def))
        su_args, blocking, nodb, nobuiltin = vg.translate(parts)
        if not nodb and not blocking:
            if nobuiltin:
                su_args.append('--nobuiltin')
            tasks.append((corpus, 'testflags', name, dirpath, su_args))

def md5(p):
    try:
        return hashlib.md5(open(p, 'rb').read()).hexdigest()
    except OSError:
        return 'none'

def run(t):
    corpus, mode, name, dirpath, su = t
    key = name + '-' + hashlib.sha1(dirpath.encode()).hexdigest()[:8]
    w = os.path.join(out, corpus, mode, key)
    os.makedirs(w, exist_ok=True)
    o = os.path.join(w, 'slang.uhdm')
    tr = os.path.join(w, 'tr')
    os.makedirs(tr, exist_ok=True)
    for f in os.listdir(tr):
        os.unlink(os.path.join(tr, f))
    if os.path.exists(o):
        os.unlink(o)
    env = dict(os.environ, R11U464_TRACE=tr)
    try:
        r = subprocess.run([law] + su + ['-o', o], cwd=dirpath, env=env,
                           stdin=subprocess.DEVNULL, capture_output=True, timeout=900)
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = 'TIMEOUT'
    fires = []
    for f in sorted(os.listdir(tr)):
        for l in open(os.path.join(tr, f)):
            if not l.startswith('OUT '):
                fires.append(l.split()[0])
    c = os.path.join(ctl, corpus, mode, key, 'slang.uhdm')
    moved = md5(o) != md5(c)
    if os.path.exists(o) and not os.environ.get('CENSUS_KEEP'):
        os.unlink(o)
    return (corpus, mode, name, rc, moved, sorted(set(fires)))

with ThreadPoolExecutor(jobs) as ex:
    res = list(ex.map(run, tasks))
n = 0
for corpus, mode, name, rc, moved, fires in res:
    n += 1
    if moved or fires:
        print(corpus, mode, name, 'rc=%s' % rc, 'MOVED' if moved else 'same', ','.join(fires))
print('rows', n, file=sys.stderr)
