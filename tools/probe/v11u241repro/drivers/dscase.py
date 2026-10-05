#!/usr/bin/env python3
# dscase.py <workroot> <binary> <case dir>...: downstream verdict per case with SLANG_UHDM=<binary> (the HEAD harness's
# one()); refuses a fenced path (fail-closed on $FENCED). Prints: <case> <verdict> <differs> <detail>.
import os, sys, re
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscase.py: source drivers/env.sh first')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
wr, b = sys.argv[1], sys.argv[2]
if not os.access(b, os.X_OK): sys.exit('dscase.py: binary not executable')
os.environ['SLANG_UHDM'] = b
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', c) for f in F): sys.exit('fenced path refused')
    n = c.split('/cases/')[-1].replace('/', '_')
    r = ds.one(n, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(n, r['verdict'], r['differs'] or '-', r['detail'] or '-', flush=True)
