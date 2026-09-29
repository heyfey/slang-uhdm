#!/usr/bin/env python3
"""dscases.py <binary> <workroot> <case dir>...: the downstream verdict (scripts/downstream_uhdm2rtlil.py one()) of every
case dir holding a dut.sv, with SLANG_UHDM=<binary>; golden cache under $GOLDEN_CACHE (a fresh one set by the caller).
Fail-closed on $FENCED (source drivers/env.sh): a path holding a fenced name is refused."""
import os, sys, re
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscases.py: source drivers/env.sh first')
if not os.environ.get('GOLDEN_CACHE'): sys.exit('dscases.py: export a fresh GOLDEN_CACHE')
b, root = sys.argv[1:3]; os.environ['SLANG_UHDM'] = b
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', c) for f in F): print(c, 'FENCED refused'); continue
    if not os.path.exists(os.path.join(c, 'dut.sv')): continue
    rel = re.sub(r'^.*/tools/probe/', '', c)
    name = re.sub(r'[^A-Za-z0-9_]', '_', rel)
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], root, 300)
    print(rel, repr(r), flush=True)
