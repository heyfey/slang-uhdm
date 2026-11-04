#!/usr/bin/env python3
"""Replay the slang-uhdm side of every gate row on two binaries (no Surelog,
no judge): rc + md5 per binary, the law binary traced (R11U491_TRACE).
Fence: every path is filtered on /tmp/r11u491_fence.txt before any file is
opened.  Usage: replay.py <pristine> <law> <outdir> <stage>..."""
import os, sys, re, glob, hashlib, subprocess, concurrent.futures
sys.path.insert(0, '/tmp/wt_r11u491/scripts')
import verify_golden as vg  # noqa
FENCE = [l.strip() for l in open('/tmp/r11u491_fence.txt') if l.strip()]
def fenced(s): return any(f in s for f in FENCE)
P, L, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
stages = sys.argv[4:]
for b in (P, L):
    assert os.access(b, os.X_OK), b
jobs = []  # (stage, name, cwd, args)
def surelog_jobs():
    for root in (os.path.join(vg.SURELOG_ROOT, 'tests'), os.path.join(vg.SURELOG_ROOT, 'third_party', 'tests')):
        for dirpath, _d, files in os.walk(root):
            if fenced(dirpath): continue
            for fn in files:
                if not fn.endswith('.sl') or fenced(fn): continue
                name = fn[:-3]
                parts = vg.preprocess_sl(os.path.join(dirpath, fn), dirpath)
                yield name, dirpath, parts
def capture(name, dirpath, parts, modes):
    got = []
    orig = vg.compare
    def fake(n, mode, dp, sl_args, su_args, workroot, timeout):
        got.append((mode, dp, su_args)); return (n, mode, 'X', '', '', '')
    vg.compare = fake
    try: vg.run_one(name, dirpath, parts, modes, '/tmp/r11u491_replay_x', 1)
    finally: vg.compare = orig
    return got
if 'surelog' in stages:
    for name, dp, parts in surelog_jobs():
        for mode, d, su in capture(name, dp, parts, ['default', 'testflags']):
            jobs.append(('surelog', name + ':' + mode, d, su))
if 'uhdm2rtlil' in stages or 'downstream' in stages:
    tests = vg.discover_uhdm2rtlil(None)
    for name, (dp, parts) in tests.items():
        if fenced(name) or fenced(dp): continue
        if 'uhdm2rtlil' in stages:
            for mode, d, su in capture(name, dp, parts, ['default', 'testflags']):
                jobs.append(('uhdm2rtlil', name + ':' + mode, d, su))
        if 'downstream' in stages:
            import downstream_uhdm2rtlil as ds
            rest = [p for p in parts if p not in ('-parse', '-nobuiltin', '-nocache')]
            sl_args = ['-parse', '-nobuiltin', '-nocache'] + ds.DOWNSTREAM_FLAGS + rest
            su, blocking, nodb, nob = vg.translate(sl_args)
            if nob: su.append('--nobuiltin')
            jobs.append(('downstream', name, dp, su))
if 'probe' in stages:
    root = os.path.join('/tmp/wt_r11u491', 'tests', 'probe')
    for g in sorted(glob.glob(os.path.join(root, '**', 'dut.sv'), recursive=True)):
        if fenced(g): continue
        jobs.append(('probe', os.path.relpath(os.path.dirname(g), root), os.path.dirname(g),
                     ['dut.sv', '--single-unit', '--nobuiltin']))
if 'svtests' in stages:
    for c in sorted(glob.glob('/tmp/intr11u489/svtests/work/**/cmds.txt', recursive=True)):
        if fenced(c): continue
        for line in open(c):
            if line.startswith('slang:'):
                argv = line.split()[1:]
                i = argv.index('-o'); argv = argv[1:i] + argv[i+2:]
                jobs.append(('svtests', os.path.relpath(os.path.dirname(c), '/tmp/intr11u489/svtests/work'), '/tmp', argv))
print(len(jobs), 'jobs', flush=True)
def run(j):
    st, name, cwd, su = j
    key = re.sub(r'[^A-Za-z0-9_.-]', '_', st + '__' + name)
    w = os.path.join(OUT, key); os.makedirs(w, exist_ok=True)
    res = []
    for tag, b in (('p', P), ('l', L)):
        o = os.path.join(w, tag + '.uhdm')
        if os.path.exists(o): os.unlink(o)
        env = dict(os.environ)
        if tag == 'l':
            td = os.path.join(w, 'trace'); os.makedirs(td, exist_ok=True); env['R11U491_TRACE'] = td
        try:
            r = subprocess.run([b] + su + ['-o', o], cwd=cwd, capture_output=True, timeout=600, env=env).returncode
        except subprocess.TimeoutExpired:
            r = 'TO'
        m = hashlib.md5(open(o, 'rb').read()).hexdigest()[:8] if os.path.isfile(o) else '-'
        res.append((r, m))
        if os.path.exists(o): os.unlink(o)
    fired = 0
    td = os.path.join(w, 'trace')
    for f in glob.glob(td + '/*'):
        fired += sum(1 for l in open(f) if not l.startswith('OUT '))
    return f"{st} {name} rcP={res[0][0]} rcL={res[1][0]} {'same' if res[0]==res[1] else 'MOVED'} trace={fired}"
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as ex:
    for line in ex.map(run, jobs):
        print(line, flush=True)
print('REPLAYDONE', flush=True)
