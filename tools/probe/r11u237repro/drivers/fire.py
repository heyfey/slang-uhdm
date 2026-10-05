#!/usr/bin/env python3
# (r11u237: copied from r11u231repro/drivers; the trace switch writes <pid>.237.)
# fire.py <binary> <tracedir> <list file of case dirs or dut.sv paths (absolute, or relative to the repo)> [--el]
# Runs the binary with R11U237_TRACE=<tracedir>/<case key> on every case, 3 at a time (the database is written to
# a scratch path and removed); prints "<case> rc=<rc> fired=<laws>" per case. Fail-closed on $FENCED.
import os, re, sys, subprocess, concurrent.futures, tempfile, shutil
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../..'))
fenced = os.environ.get('FENCED', '').split()
if len(fenced) != 4:
    sys.exit('fire: FENCED unset')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, fenced)) + r')\b')
b, tdir, lst = sys.argv[1], sys.argv[2], sys.argv[3]
el = '--el' in sys.argv
if not os.access(b, os.X_OK):
    sys.exit('fire: binary not executable')
os.makedirs(tdir, exist_ok=True)
cases = []
for line in open(lst):
    p = line.strip()
    if not p:
        continue
    if not os.path.isabs(p):
        p = os.path.join(REPO, 'tools/probe', p) if not p.startswith(('tools/', 'tests/')) else os.path.join(REPO, p)
    if p.endswith('.sv') or p.endswith('.v'):
        p = os.path.dirname(p)
    if fre.search(p):
        continue
    cases.append(p)
scr = tempfile.mkdtemp(prefix='r11u237_fire_')
def one(c):
    key = os.path.relpath(c, REPO).replace('/', '__')
    src = ['dut.sv'] if os.path.isfile(os.path.join(c, 'dut.sv')) else ['dut.v']
    if os.path.isfile(os.path.join(c, 'args')):
        src = open(os.path.join(c, 'args')).read().split()
    td = os.path.join(tdir, key); os.makedirs(td, exist_ok=True)
    out = os.path.join(scr, key + '.uhdm')
    env = dict(os.environ, R11U237_TRACE=td)
    try:
        r = subprocess.run([b] + src + ['--single-unit', '--nobuiltin'] + (['--elabuhdm'] if el else []) + ['-o', out],
                           cwd=c, env=env, capture_output=True, timeout=300).returncode
    except subprocess.TimeoutExpired:
        r = 'timeout'
    try: os.unlink(out)
    except OSError: pass
    laws = set()
    for fn in os.listdir(td):
        for l in open(os.path.join(td, fn)):
            if not l.startswith('OUT '):
                laws.add(l.split()[0])
    if not laws:
        shutil.rmtree(td, ignore_errors=True)
    return f'{os.path.relpath(c, REPO)} rc={r} fired={",".join(sorted(laws)) or "-"}'
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    for l in ex.map(one, cases):
        print(l, flush=True)
shutil.rmtree(scr, ignore_errors=True)
