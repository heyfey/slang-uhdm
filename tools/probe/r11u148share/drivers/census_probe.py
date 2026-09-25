#!/usr/bin/env python3
"""census_probe.py <binary> <outdir> [jobs]: every tests/probe case (check_probe's SU_ARGS) with R11U148_TRACE=1."""
import os, sys, glob, subprocess
from concurrent.futures import ThreadPoolExecutor
ROOT = '/tmp/wt_r11u148/tests/probe'
binary, out = sys.argv[1], sys.argv[2]
jobs = int(sys.argv[3]) if len(sys.argv) > 3 else 3
cases = sorted(os.path.relpath(os.path.dirname(g), ROOT) for g in glob.glob(ROOT + '/**/dut.sv', recursive=True))
def run(rel):
    o = os.path.join(out, 'probe', rel.replace('/', '__') + '.uhdm')
    os.makedirs(os.path.dirname(o), exist_ok=True)
    try: os.unlink(o)
    except FileNotFoundError: pass
    p = subprocess.run([binary, 'dut.sv', '--single-unit', '--nobuiltin', '-o', o], cwd=os.path.join(ROOT, rel),
                       capture_output=True, text=True, timeout=600, errors='replace',
                       env=dict(os.environ, R11U148_TRACE='1'))
    return rel, p.returncode, [l for l in p.stderr.splitlines() if l.startswith('R11U148')]
with ThreadPoolExecutor(jobs) as ex, open(os.path.join(out, 'census_probe.txt'), 'w') as f:
    for rel, rc, tr in ex.map(run, cases):
        for t in tr:
            f.write(f'{rel}\t{t}\n')
print('cases', len(cases))
