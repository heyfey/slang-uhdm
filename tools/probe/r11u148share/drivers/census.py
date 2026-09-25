#!/usr/bin/env python3
"""census.py <binary> <pristine sweep workdir> <outdir> [jobs]
Re-runs every corpus command the pristine sweep ran (cmds.txt 'slang:' line, cwd = the test dir from
verify_golden's discovery) with <binary> and R11U148_TRACE=1; collects the R11U148 trace lines per row and keeps
the database (<outdir>/<corpus>/<mode>/<dir>/slang.uhdm) for a byte comparison with the law sweep.
The slang-fenced tests are never dispatched (FENCED below)."""
import os, sys, re, shlex, subprocess, glob
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, '/tmp/wt_r11u148/scripts')
import verify_golden as vg
FENCED = {'UnsignedParam', 'HierPathEval', 'FileLocalParam', 'TopParam'}
binary, swp, out = sys.argv[1], sys.argv[2], sys.argv[3]
jobs = int(sys.argv[4]) if len(sys.argv) > 4 else 3
dirs = {'surelog': {k: v[0] for k, v in vg.discover_surelog(None).items()},
        'uhdm2rtlil': {k: v[0] for k, v in vg.discover_uhdm2rtlil(None).items()}}
work = []
for corpus in ('surelog', 'uhdm2rtlil'):
    for mode in ('default', 'testflags'):
        for d in sorted(glob.glob(os.path.join(swp, corpus, mode, '*', 'cmds.txt'))):
            rowdir = os.path.basename(os.path.dirname(d))
            name = rowdir.rsplit('-', 1)[0]
            if name in FENCED:
                continue
            line = [l for l in open(d) if l.startswith('slang:')]
            if not line:
                continue
            args = shlex.split(line[0][len('slang:'):])
            argv = args[1:]
            i = argv.index('-o')
            o = os.path.join(out, corpus, mode, rowdir, 'slang.uhdm')
            argv = argv[:i] + ['-o', o] + argv[i + 2:]
            work.append((corpus, mode, name, dirs[corpus][name], argv, o))
def run(w):
    corpus, mode, name, cwd, argv, o = w
    os.makedirs(os.path.dirname(o), exist_ok=True)
    try: os.unlink(o)
    except FileNotFoundError: pass
    env = dict(os.environ, R11U148_TRACE='1')
    try:
        p = subprocess.run([binary] + argv, cwd=cwd, capture_output=True, text=True, timeout=900, env=env,
                           errors='replace')
        tr = [l for l in p.stderr.splitlines() if l.startswith('R11U148')]
        return corpus, mode, name, p.returncode, tr
    except subprocess.TimeoutExpired:
        return corpus, mode, name, 'TIMEOUT', []
with ThreadPoolExecutor(jobs) as ex, open(os.path.join(out, 'census.txt'), 'w') as f:
    for corpus, mode, name, rc, tr in ex.map(run, work):
        for t in tr:
            f.write(f'{corpus}\t{mode}\t{name}\t{t}\n')
        f.write(f'#row\t{corpus}\t{mode}\t{name}\trc={rc}\ttraces={len(tr)}\n')
print('rows', len(work))
