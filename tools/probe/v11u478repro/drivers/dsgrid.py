#!/usr/bin/env python3
# dsgrid.py <bin> <tag> <casedir>...: downstream verdict of one case (scripts/downstream_uhdm2rtlil.py's one()),
# Surelog lane uhdm2rtlil's own Surelog, slang lane <bin>; workroot /tmp/v11u478_ds_<tag>.  Run from the worktree root.
import os, sys
sys.path.insert(0, 'scripts')
binp, tag, dirs = sys.argv[1], sys.argv[2], sys.argv[3:]
os.environ['SLANG_UHDM'] = binp
import verify_golden as vg
vg.SLANG_UHDM = binp
import downstream_uhdm2rtlil as ds
for d in dirs:
    d = os.path.realpath(d)
    if not os.path.isdir(d):
        continue
    name = d.split('/cases/')[-1].replace('/', '_')
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/v11u478_ds_' + tag, 300)
    print(d.split('/cases/')[-1], tag, r['verdict'], r['differs'], r['surelog_status'], r['slang_status'])
