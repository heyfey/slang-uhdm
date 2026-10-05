#!/usr/bin/env python3
# (r11u242: copied from r11u240repro/drivers; trace variable R11U242_TRACE)
# (r11u238 (from r11u236repro): copied from r11u232repro/drivers)
"""dscensus.py <out dir> <trace dir> [jobs]: the downstream-lane firing census (r11u242repro).  For every uhdm2rtlil
test the downstream harness (scripts/downstream_uhdm2rtlil.py `one`) runs, the law binary ($SLANG_UHDM) is run with
the harness's own translated command line (the downstream flags, -DSYNTHESIS) and R11U242_TRACE set,
writing <out dir>/<test>.uhdm; predict.py then names every lane whose process fired.  No Yosys run.  Fail-closed on
the fence: the four names of the FENCED= line of tools/probe/r11u107repro/canaudit.sh are refused (word boundary)."""
import os, re, sys, subprocess, concurrent.futures
R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
F = next((l.split('=', 1)[1].strip().strip('"\'').split() for l in open(os.path.join(R, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')), [])
if len(F) != 4: sys.exit('dscensus: fence unreadable')
sys.path.insert(0, os.path.join(R, 'scripts'))
import verify_golden as vg
import downstream_uhdm2rtlil as ds
OUT, TR = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
J = int(sys.argv[3]) if len(sys.argv) > 3 else 3
os.makedirs(OUT, exist_ok=True); os.makedirs(TR, exist_ok=True)
env = dict(os.environ, R11U242_TRACE=TR)
tests = vg.discover_uhdm2rtlil(None)
def fenced(n): return any(re.search(r'(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])' % re.escape(f), n) for f in F)
def run(item):
    name, (d, parts) = item
    if fenced(name): return name, 'FENCED'
    rest = [p for p in parts if p not in ('-parse', '-nobuiltin', '-nocache')]
    su, _b, _n, nob = vg.translate(['-parse', '-nobuiltin', '-nocache'] + ds.DOWNSTREAM_FLAGS + rest)
    if nob: su = su + ['--nobuiltin']
    o = os.path.join(OUT, name + '.uhdm')
    if os.path.exists(o): os.unlink(o)
    try:
        r = subprocess.run([vg.SLANG_UHDM] + su + ['-o', o], cwd=d, env=env, capture_output=True, timeout=300)
        return name, str(r.returncode)
    except subprocess.TimeoutExpired:
        return name, 'TIMEOUT'
with concurrent.futures.ThreadPoolExecutor(max_workers=J) as p:
    res = list(p.map(run, sorted(tests.items())))
print(len(res), 'lanes;', sum(1 for _, r in res if r == 'FENCED'), 'fenced skipped')
