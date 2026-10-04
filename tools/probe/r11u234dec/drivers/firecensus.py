#!/usr/bin/env python3
"""firecensus.py <law binary> <out dir> [jobs]: the r11u234 FIRING CENSUS (not the gate sweep): every surelog and
uhdm2rtlil row in both modes, every probe case and every downstream lane, dispatched with the harness's OWN slang-uhdm
command line (this checkout's scripts/verify_golden.py, check_probe.py, downstream_uhdm2rtlil.py construct it; the
fence is applied here in-process from the FENCED= line of tools/probe/r11u107repro/canaudit.sh, so no fenced name ever
reaches a command line), with R11U234_TRACE=<out dir>/trace: one trace file per process naming each law firing. The
databases are written to <out dir>/db and deleted. Writes <out dir>/census.tsv (job, laws with counts) and prints
the per-law totals. The job list itself is written to <out dir>/jobs.tsv (the fenced rows never enter it)."""
import os, sys, re, glob, subprocess, collections, concurrent.futures as cf
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
sys.path.insert(0, os.path.join(REPO, 'tools', 'probe', 'r11u230map', 'drivers'))
import common
F = common.fenced()
import verify_golden as vg, check_probe as cp, downstream_uhdm2rtlil as ds
LAW, OUT = sys.argv[1], sys.argv[2]
NJ = int(sys.argv[3]) if len(sys.argv) > 3 else 3
if not os.access(LAW, os.X_OK): sys.exit('firecensus.py: law binary not executable')
T = os.path.join(OUT, 'trace'); DB = os.path.join(OUT, 'db')
os.makedirs(T, exist_ok=True); os.makedirs(DB, exist_ok=True)
jobs = []  # (tag, cwd, args)
def fenced(*s): return common.is_fenced(' '.join(s), F)
nf = 0
for corpus, disc in (('surelog', vg.discover_surelog), ('uhdm2rtlil', vg.discover_uhdm2rtlil)):
    for name, (dirpath, parts) in disc(None).items():
        if fenced(name, dirpath): nf += 1; continue
        if name in vg.DEFERRED_TESTS: continue
        sources, _o = vg.split_sources(parts)
        loc, _sl = vg.location_args(parts)
        jobs.append((f'{corpus}/default/{name}', dirpath,
                     [vg.LOCATION_RENAME.get(a, a) for a in loc] + list(sources) + ['--single-unit']))
        su, blocking, nodb, nob = vg.translate(parts)
        if not blocking and not nodb:
            if nob: su = su + ['--nobuiltin']
            jobs.append((f'{corpus}/testflags/{name}', dirpath, su))
        if corpus == 'uhdm2rtlil':
            rest = [p for p in parts if p not in ('-parse', '-nobuiltin', '-nocache')]
            sl = ['-parse', '-nobuiltin', '-nocache'] + ds.DOWNSTREAM_FLAGS + rest
            su2, b2, n2, nob2 = vg.translate(sl)
            if nob2: su2 = su2 + ['--nobuiltin']
            jobs.append((f'downstream/lane/{name}', dirpath, su2))
for rel in cp.cases(None):
    if fenced(rel): nf += 1; continue
    jobs.append((f'probe/case/{rel}', os.path.join(cp.ROOT, rel), list(cp.SU_ARGS)))
with open(os.path.join(OUT, 'jobs.tsv'), 'w') as f:
    for t, c, a in jobs: f.write(f'{t}\t{c}\t{" ".join(a)}\n')
print(f'jobs={len(jobs)} fenced_skipped={nf}', flush=True)
def run(j):
    t, cwd, args = j
    o = os.path.join(DB, re.sub(r'[^A-Za-z0-9_.-]', '_', t) + '.uhdm')
    if os.path.exists(o): os.unlink(o)
    env = dict(os.environ, R11U234_TRACE=T)
    try:
        r = subprocess.run([LAW] + args + ['-o', o], cwd=cwd, env=env, capture_output=True, timeout=900)
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = 'TIMEOUT'
    if os.path.exists(o): os.unlink(o)
    return t, o, rc
omap = {}; rcs = {}
with cf.ThreadPoolExecutor(NJ) as ex:
    for t, o, rc in ex.map(run, jobs):
        omap[o] = t; rcs[t] = rc
fires = collections.defaultdict(collections.Counter)
for fn in glob.glob(os.path.join(T, '*.234')):
    lines = open(fn, errors='replace').read().splitlines()
    if not lines or not lines[0].startswith('OUT '): continue
    t = omap.get(lines[0][4:], '?' + lines[0][4:])
    for l in lines[1:]:
        fires[t][l.split(' ', 1)[0]] += 1
tot = collections.Counter(); rows = collections.Counter()
with open(os.path.join(OUT, 'census.tsv'), 'w') as f:
    for t, _c, _a in jobs:
        c = fires.get(t)
        f.write(f'{t}\trc={rcs.get(t)}\t' + (' '.join(f'{k}={v}' for k, v in sorted(c.items())) if c else '-') + '\n')
        if c:
            for k, v in c.items(): tot[k] += v; rows[k] += 1
for k in sorted(tot): print(f'{k}: firings={tot[k]} jobs={rows[k]}')
print('jobs_firing=', sum(1 for t in fires if not t.startswith('?')), 'unmapped=', sum(1 for t in fires if t.startswith('?')))
