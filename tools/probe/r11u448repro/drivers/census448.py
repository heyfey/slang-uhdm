#!/usr/bin/env python3
"""Trace census of a law binary (R11U448_TRACE) before the sweep, against the master's control
sweep at the base (/tmp/intr11u446, pristine binary).  Fence-filtered first (the fence list is a
file of names, read by a program, never printed).
  probe:   every tests/probe case; md5 of the law output against the control's <rel__>.uhdm
  surelog|uhdm2rtlil: every control cmds.txt slang line, both modes; md5 against the control output
  svtests: every control cmds.txt slang line (work/<row>/cmds.txt); rc and firings (the control
           keeps no database on identical rows)
usage: census448.py <mode> <control dir> <fence file> <law> <workdir> <out.tsv> [jobs]"""
import glob, hashlib, os, shlex, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
mode, ctl, fence, law, wd, out = sys.argv[1:7]
jobs = int(sys.argv[7]) if len(sys.argv) > 7 else 3
REPO = '/tmp/wt_r11u448'
fenced = [l.strip() for l in open(fence) if l.strip()]
def ok(p): return not any(f in p for f in fenced)
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()[:8]
    except OSError: return 'NONE'
rows = []  # (key, argv, cwd, ctl_out)
if mode == 'probe':
    root = os.path.join(REPO, 'tests/probe')
    for g in sorted(glob.glob(os.path.join(root, '**', 'dut.sv'), recursive=True)):
        rel = os.path.relpath(os.path.dirname(g), root)
        if not ok(rel): continue
        rows.append((rel, [law, 'dut.sv', '--single-unit', '--nobuiltin', '-o', None],
                     os.path.dirname(g), os.path.join(ctl, 'probe', rel.replace('/', '__') + '.uhdm')))
elif mode in ('surelog', 'uhdm2rtlil'):
    sys.path.insert(0, os.path.join(REPO, 'scripts'))
    import verify_golden as vg
    tests = vg.discover_surelog(None) if mode == 'surelog' else vg.discover_uhdm2rtlil(None)
    for m in ('default', 'testflags'):
        md = os.path.join(ctl, mode, m)
        for e in sorted(os.listdir(md)):
            if not ok(e): continue
            name = e.rsplit('-', 1)[0]
            cf = os.path.join(md, e, 'cmds.txt')
            if name not in tests or not os.path.isfile(cf): continue
            line = [l for l in open(cf) if l.startswith('slang:')]
            if not line: continue
            argv = shlex.split(line[0][len('slang:'):])
            o = argv.index('-o'); co = argv[o + 1]; argv[0] = law; argv[o + 1] = None
            cwd = tests[name][0] if mode == 'surelog' else os.path.join(vg.UHDM2RTLIL_TESTS, name)
            rows.append((m + '/' + name, argv, cwd, co))
elif mode == 'svtests':
    for cf in sorted(glob.glob(os.path.join(ctl, 'svtests', 'work', '**', 'cmds.txt'), recursive=True)):
        key = os.path.relpath(os.path.dirname(cf), os.path.join(ctl, 'svtests', 'work'))
        if not ok(key): continue
        line = [l for l in open(cf) if l.startswith('slang:')]
        if not line: continue
        argv = shlex.split(line[0][len('slang:'):])
        o = argv.index('-o'); argv[0] = law; argv[o + 1] = None
        rows.append((key, argv, None, None))
def one(r):
    key, argv, cwd, co = r
    d = os.path.join(wd, key.replace('/', '__')); tr = os.path.join(d, 'tr')
    os.makedirs(tr, exist_ok=True)
    for t in os.listdir(tr): os.remove(os.path.join(tr, t))
    o = os.path.join(d, 'law.uhdm')
    if os.path.exists(o): os.remove(o)
    argv = [o if a is None else a for a in argv]
    env = dict(os.environ, R11U448_TRACE=tr)
    try:
        rc = subprocess.run(argv, cwd=cwd or d, env=env, stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL, timeout=900).returncode
    except subprocess.TimeoutExpired:
        rc = 'TO'
    fl = []
    for t in os.listdir(tr):
        fl += [l.strip() for l in open(os.path.join(tr, t)) if not l.startswith('OUT')]
    adm = sum(1 for l in fl if not l.split(' ', 2)[1:2] == ['abstain'])
    mine = md5(o); ref = md5(co) if co else '-'
    if co is None or mine == ref:
        try: os.remove(o)
        except OSError: pass
    return f'{key}\t{rc}\t{ref}\t{mine}\t{len(fl)}\t{adm}\t{";".join(fl)[:400]}'
with ThreadPoolExecutor(jobs) as ex, open(out, 'w') as f:
    for s in ex.map(one, rows):
        f.write(s + '\n'); f.flush()
print(len(rows), 'rows')
