#!/usr/bin/env python3
# usage: ds.py <tree> <bin> <workroot> <casedir>...  -> case verdict row (downstream harness one())
import sys, os, re
tree, b, wr, dirs = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
FEN = os.environ['FENCED'].split(); assert len(FEN) == 4
os.environ['SLANG_UHDM'] = b
sys.path.insert(0, tree + '/scripts')
import verify_golden as vg; vg.SLANG_UHDM = b
import downstream_uhdm2rtlil as ds
for d in dirs:
    d = os.path.abspath(d)
    assert not any(re.search(r'\b%s\b' % f, d) for f in FEN)
    name = d.replace('/tmp/v11u186_cases/', '').replace('/', '_')
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(os.path.basename(b), d.replace('/tmp/v11u186_cases/', ''), r, flush=True)
