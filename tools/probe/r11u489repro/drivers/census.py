#!/usr/bin/env python3
"""census.py <bin> <outdir>: run <bin> with R11U489_TRACE on every row of the
probe, surelog (both modes), uhdm2rtlil (both modes) and sv-tests corpora, with
the command each row's control cmds.txt (the master's control sweep at the
base, /tmp/intr11u487) recorded, the output redirected to <outdir>; prints per
row the exit code, whether the trace fired and whether the bytes equal the
control's database (when the control kept one).  Paths are fence-filtered
before any file is opened."""
import os, sys, shlex, subprocess, hashlib, glob
from concurrent.futures import ThreadPoolExecutor
WT = '/tmp/wt_r11u489'
sys.path.insert(0, os.path.join(WT, 'scripts'))
import verify_golden as vg
CTL = '/tmp/intr11u487'
BIN, OUT = sys.argv[1], sys.argv[2]
FENCE = [l.strip() for l in open('/tmp/r11u489_fence.txt') if l.strip()]
fenced = lambda s: any(f in s for f in FENCE)
jobs = []
# names and directories only (no test file is opened): Surelog's *.sl tests
# and uhdm2rtlil's test dirs, fence-filtered, keyed as verify_golden.py keys
# its workdirs
cands = []
for root in (os.path.join(vg.SURELOG_ROOT, 'tests'), os.path.join(vg.SURELOG_ROOT, 'third_party', 'tests')):
    for dirpath, _d, files in os.walk(root):
        for fn in files:
            if fn.endswith('.sl'):
                cands.append(('surelog', fn[:-3], dirpath))
for name in sorted(os.listdir(vg.UHDM2RTLIL_TESTS)):
    cands.append(('uhdm2rtlil', name, os.path.join(vg.UHDM2RTLIL_TESTS, name)))
for corpus, name, dirpath in cands:
    if fenced(name) or fenced(dirpath):
        continue
    key = name + '-' + hashlib.sha1(dirpath.encode()).hexdigest()[:8]
    for mode in ('default', 'testflags'):
        cdir = os.path.join(CTL, corpus, mode, key)
        if os.path.isdir(cdir):
            jobs.append((corpus + '/' + mode + '/' + key, dirpath, os.path.join(cdir, 'cmds.txt'),
                         os.path.join(cdir, 'slang.uhdm')))
proot = os.path.join(WT, 'tests', 'probe')
for g in sorted(glob.glob(os.path.join(proot, '**', 'dut.sv'), recursive=True)):
    rel = os.path.relpath(os.path.dirname(g), proot)
    if fenced(rel):
        continue
    jobs.append(('probe/' + rel, os.path.dirname(g), None,
                 os.path.join(CTL, 'probe', rel.replace('/', '__') + '.uhdm')))
for cf in sorted(glob.glob(os.path.join(CTL, 'svtests', 'work', '**', 'cmds.txt'), recursive=True)):
    if fenced(cf):
        continue
    d = os.path.dirname(cf)
    jobs.append(('svtests/' + os.path.relpath(d, os.path.join(CTL, 'svtests', 'work')), d, cf,
                 os.path.join(d, 'slang.uhdm')))

def one(j):
    tag, cwd, cf, ctl = j
    safe = tag.replace('/', '__')
    out = os.path.join(OUT, 'db', safe + '.uhdm'); tr = os.path.join(OUT, 'tr', safe)
    os.makedirs(tr, exist_ok=True)
    if cf is None:
        argv = [BIN, '-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv', '--single-unit', '--nobuiltin']
        # the probe's own argv
        import check_probe as cp
        argv = [BIN] + cp.SU_ARGS
    else:
        if not os.path.isfile(cf):
            return tag + ' NOCTL'
        line = [l for l in open(cf) if l.startswith('slang:')]
        if not line:
            return tag + ' NOSLANG'
        argv = shlex.split(line[0][len('slang:'):])
        if '-o' in argv:
            i = argv.index('-o'); del argv[i:i + 2]
        argv[0] = BIN
    argv += ['-o', out]
    try:
        os.unlink(out)
    except FileNotFoundError:
        pass
    env = dict(os.environ, R11U489_TRACE=tr)
    try:
        r = subprocess.run(argv, cwd=cwd, env=env, capture_output=True, timeout=600)
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = 'TIMEOUT'
    fired = sum(1 for f in os.listdir(tr) for _ in open(os.path.join(tr, f)))
    if os.path.isfile(ctl) and os.path.isfile(out):
        same = 'same' if open(ctl, 'rb').read() == open(out, 'rb').read() else 'MOVED'
    else:
        same = 'noctl'
    if os.path.isfile(out) and same != 'MOVED':
        os.unlink(out)
    return '%s rc=%s fired=%d %s' % (tag, rc, fired, same)

os.makedirs(os.path.join(OUT, 'db'), exist_ok=True)
with ThreadPoolExecutor(3) as ex:
    for res in ex.map(one, jobs):
        print(res, flush=True)
