#!/usr/bin/env python3
# v11u425 downstream verdicts per case dir: ds.py <binary> <workroot> <case dirs...>; prints case verdict differs
import os, sys
sys.path.insert(0, '/tmp/wt_v11u425/scripts')
import downstream_uhdm2rtlil as ds
ds.vg.SLANG_UHDM = sys.argv[1]
for c in sys.argv[3:]:
    d = os.path.abspath(c)
    name = c.replace('/', '_')
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], sys.argv[2], 300)
    print(c, r['verdict'], r.get('differs', ''), flush=True)
