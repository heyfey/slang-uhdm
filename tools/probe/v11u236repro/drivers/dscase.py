#!/usr/bin/env python3
# v11u236: the downstream verdict of fresh cases (scripts/downstream_uhdm2rtlil.py `one`), one binary per run.
# usage: dscase.py <binary> <workroot> <out> <case dir>...   Fail-closed on $FENCED (a path naming a fenced test is refused).
import os, re, sys, concurrent.futures
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscase: FENCED not set (source drivers/env.sh)')
R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
BIN, WR, OUT = sys.argv[1:4]; cases = sys.argv[4:]
if not os.access(BIN, os.X_OK): sys.exit('dscase: binary not executable')
os.environ['SLANG_UHDM'] = BIN
sys.path.insert(0, os.path.join(R, 'scripts'))
import downstream_uhdm2rtlil as ds
def run(c):
    c = os.path.abspath(c)
    if any(re.search(r'\b%s\b' % re.escape(n), c) for n in F): return c, 'FENCED'
    name = re.sub(r'.*/cases/', '', c).replace('/', '_')
    w = os.path.join(WR, name); os.makedirs(w, exist_ok=True)
    try: return c, ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], w, 300)
    except Exception as e: return c, 'ERROR %s' % e
with concurrent.futures.ThreadPoolExecutor(3) as ex, open(OUT, 'w') as o:
    for c, r in ex.map(run, cases):
        o.write('%s %s\n' % (re.sub(r'.*/cases/', '', c), r))
