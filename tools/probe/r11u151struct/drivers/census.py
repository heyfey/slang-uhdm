#!/usr/bin/env python3
"""census.py <binary> <pristine sweep workdir> <outdir> [jobs]
The mover PREDICTOR.  Re-runs every corpus command the pristine sweep ran (cmds.txt 'slang:' line, cwd = the
test dir from verify_golden's discovery) and every tests/probe case (check_probe's arguments) with <binary> and
R11U151_TRACE=1, and records the `R11U151 <law>` lines per row / case: a row or case with a trace line is a
PREDICTED mover.  FAIL-CLOSED on the slang-fenced tests: a fenced name is never dispatched, and a command whose
argv or cwd names a fenced test aborts the whole census before anything runs."""
import os, sys, shlex, subprocess, glob
from concurrent.futures import ThreadPoolExecutor
HERE = os.path.dirname(os.path.abspath(__file__))
WT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(WT, 'scripts'))
import verify_golden as vg
FENCED = {'UnsignedParam', 'HierPathEval', 'FileLocalParam', 'TopParam'}
binary, swp, out = sys.argv[1], sys.argv[2], sys.argv[3]
jobs = int(sys.argv[4]) if len(sys.argv) > 4 else 3
dirs = {'surelog': {k: v[0] for k, v in vg.discover_surelog(None).items()},
        'uhdm2rtlil': {k: v[0] for k, v in vg.discover_uhdm2rtlil(None).items()}}
work, skipped = [], []
for corpus in ('surelog', 'uhdm2rtlil'):
    for mode in ('default', 'testflags'):
        for d in sorted(glob.glob(os.path.join(swp, corpus, mode, '*', 'cmds.txt'))):
            rowdir = os.path.basename(os.path.dirname(d))
            name = rowdir.rsplit('-', 1)[0]
            if name in FENCED:
                skipped.append((corpus, mode, name))
                continue
            line = [l for l in open(d) if l.startswith('slang:')]
            if not line:
                continue
            argv = shlex.split(line[0][len('slang:'):])[1:]
            i = argv.index('-o')
            o = os.path.join(out, corpus, mode, rowdir, 'slang.uhdm')
            argv = argv[:i] + ['-o', o] + argv[i + 2:]
            work.append(('row', f'{corpus}\t{mode}\t{name}', dirs[corpus][name], argv, o))
PROBE = os.path.join(WT, 'tests', 'probe')
for g in sorted(glob.glob(PROBE + '/**/dut.sv', recursive=True)):
    rel = os.path.relpath(os.path.dirname(g), PROBE)
    o = os.path.join(out, 'probe', rel.replace('/', '__') + '.uhdm')
    work.append(('case', f'probe\t-\t{rel}', os.path.dirname(g), ['dut.sv', '--single-unit', '--nobuiltin', '-o', o], o))
# fail closed: nothing that names a fenced test may run
for kind, key, cwd, argv, o in work:
    blob = ' '.join([cwd] + argv)
    for f in FENCED:
        if f in blob.split('/') or ('/' + f + '/') in blob or blob.endswith('/' + f):
            sys.exit(f'FENCE: {key} names {f}; census aborted before any dispatch')
def run(w):
    kind, key, cwd, argv, o = w
    os.makedirs(os.path.dirname(o), exist_ok=True)
    try: os.unlink(o)
    except FileNotFoundError: pass
    env = dict(os.environ, R11U151_TRACE='1')
    try:
        p = subprocess.run([binary] + argv, cwd=cwd, capture_output=True, text=True, timeout=900, env=env,
                           errors='replace')
        return key, p.returncode, [l for l in p.stderr.splitlines() if l.startswith('R11U151 ')]
    except subprocess.TimeoutExpired:
        return key, 'TIMEOUT', []
with ThreadPoolExecutor(jobs) as ex, open(os.path.join(out, 'census.txt'), 'w') as f:
    for key, rc, tr in ex.map(run, work):
        laws = sorted(set(t.split()[1] for t in tr))
        f.write(f'{key}\trc={rc}\ttraces={len(tr)}\tlaws={",".join(laws)}\n')
with open(os.path.join(out, 'fenced_skipped.txt'), 'w') as f:
    for s in skipped:
        f.write('\t'.join(s[:2]) + '\tFENCED\n')
print('dispatched', len(work), 'fenced-skipped', len(skipped))
