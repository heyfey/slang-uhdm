#!/usr/bin/env python3
"""Byte census of a law binary against the master's control sweep (pristine binary) on the
surelog and uhdm2rtlil corpora: re-runs each control cmds.txt slang line with LAW (traced) in
the test's own directory, compares md5 with the control's slang.uhdm.  Fence-filtered first.
usage: corpus_census.py <control dir> <corpus> <fence file> <law> <workdir> <out.tsv> [jobs]"""
import hashlib, os, re, shlex, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, '/tmp/wt_r11u447/scripts')
import verify_golden as vg
ctl, corpus, fence, law, wd, out = sys.argv[1:7]
jobs = int(sys.argv[7]) if len(sys.argv) > 7 else 3
fenced = [l.strip() for l in open(fence) if l.strip()]
tests = vg.discover_surelog(None) if corpus == 'surelog' else vg.discover_uhdm2rtlil(None)
rows = []
for mode in ('default', 'testflags'):
    md = os.path.join(ctl, corpus, mode)
    for e in sorted(os.listdir(md)):
        if any(f in e for f in fenced):
            continue
        name = e.rsplit('-', 1)[0]
        cf = os.path.join(md, e, 'cmds.txt')
        if name not in tests or not os.path.isfile(cf):
            continue
        rows.append((mode, name, e, cf))
def md5(p):
    try:
        return hashlib.md5(open(p, 'rb').read()).hexdigest()[:8]
    except OSError:
        return 'NONE'
def one(r):
    mode, name, e, cf = r
    line = [l for l in open(cf) if l.startswith('slang:')]
    if not line:
        return f'{mode}\t{name}\tNOSLANG'
    argv = shlex.split(line[0][len('slang:'):])
    o = argv.index('-o')
    ctl_out = argv[o + 1]
    d = os.path.join(wd, mode, e); os.makedirs(os.path.join(d, 'tr'), exist_ok=True)
    mine = os.path.join(d, 'law.uhdm')
    if os.path.exists(mine): os.remove(mine)
    argv[0] = law; argv[o + 1] = mine
    dirpath = tests[name][0] if corpus == 'surelog' else os.path.join(vg.UHDM2RTLIL_TESTS, name)
    env = dict(os.environ, R11U447_TRACE=os.path.join(d, 'tr'))
    try:
        rc = subprocess.run(argv, cwd=dirpath, env=env, stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL, timeout=600).returncode
    except subprocess.TimeoutExpired:
        rc = 'TO'
    fi = 0
    for t in os.listdir(os.path.join(d, 'tr')):
        fi += sum(1 for l in open(os.path.join(d, 'tr', t)) if not l.startswith('OUT'))
    return f'{mode}\t{name}\t{rc}\t{md5(ctl_out)}\t{md5(mine)}\t{fi}'
with ThreadPoolExecutor(jobs) as ex, open(out, 'w') as f:
    for s in ex.map(one, rows):
        f.write(s + '\n')
print(len(rows), 'rows')
