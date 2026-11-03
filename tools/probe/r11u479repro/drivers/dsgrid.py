#!/usr/bin/env python3
"""dsgrid.py <bin> <tag> <case dir>...: downstream verdict of each case dir through
scripts/downstream_uhdm2rtlil.one (the Surelog lane with uhdm2rtlil's own Surelog and
the downstream flags, the slang lane with <bin>); prints case, verdict, differs."""
import os, sys
sys.path.insert(0, '/tmp/wt_r11u479/scripts')
B, T = sys.argv[1], sys.argv[2]
assert os.access(B, os.X_OK), B
os.environ['SLANG_UHDM'] = B
import verify_golden as vg
vg.SLANG_UHDM = B
import downstream_uhdm2rtlil as ds
for d in sys.argv[3:]:
    d = os.path.abspath(d)
    name = d.replace('/', '_')[-60:]
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/r11u479_ds_' + T, 300)
    print(d.split('/cases/')[-1], T, r['verdict'], r['differs'], flush=True)
