#!/usr/bin/env python3
"""dscases.py <binary> <workroot> <case dir>...: the downstream gate's own machinery on cases
(scripts/downstream_uhdm2rtlil.py one(): uhdm2rtlil's Surelog with the downstream flags vs slang-uhdm with the
translated command line, Yosys through the uhdm2rtlil plugin). A case with an `args` file passes its files.
Prints `<case> <verdict> <differs>`. Set GOLDEN_CACHE to a fresh directory for edited cases. Fenced paths refused."""
import os, sys, re
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscases.py: source drivers/env.sh first')
BIN, WR = sys.argv[1:3]
os.environ['SLANG_UHDM'] = BIN
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(x)}(?![A-Za-z0-9_])', c) for x in F):
        print(c, 'FENCED-REFUSED'); continue
    files = open(os.path.join(c, 'args')).read().split() if os.path.exists(os.path.join(c, 'args')) else ['dut.sv']
    name = re.sub(r'.*/r11u218dec/cases/', '', c).replace('/', '__')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv'] + files, WR, 300)
    print(name, r['verdict'], r['differs'] or '-', flush=True)
