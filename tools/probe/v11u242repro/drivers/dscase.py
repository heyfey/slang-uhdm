#!/usr/bin/env python3
# (v11u242: copied from v11u240repro/drivers)
# (v11u240) dscase.py <workroot> <casedir>...: the downstream verdict of each case (dut.sv) under $SLANG_UHDM, through
# scripts/downstream_uhdm2rtlil.py's one(); prints <case> <verdict> <differs>. Fail-closed on $FENCED.
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscase.py: source drivers/env.sh first')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
wr = sys.argv[1]
for c in sys.argv[2:]:
    c = os.path.abspath(c)
    if any(re.search(rf'\b{re.escape(f)}\b', c) for f in F): sys.exit('fenced')
    name = c.split('/cases/')[-1].replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(c.split('/cases/')[-1], r, flush=True)
