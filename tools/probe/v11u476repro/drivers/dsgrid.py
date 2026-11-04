#!/usr/bin/env python3
# dsgrid.py <tag> <binary> <workroot> <casedir>...: the downstream verdict of each case dir
# through scripts/downstream_uhdm2rtlil.py's one() (the surelog lane with the downstream flags,
# the slang lane on <binary>); one line per case.  Run from the worktree root.
import os, sys
tag, b, wr = sys.argv[1:4]
os.environ['SLANG_UHDM'] = b
sys.path.insert(0, 'scripts')
import downstream_uhdm2rtlil as ds
for c in sys.argv[4:]:
    c = os.path.realpath(c)
    if not os.path.isdir(c):
        continue
    name = c.split('/cases/')[1].replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], os.path.join(wr, tag), 300)
    print(c.split('/cases/')[1], tag, r['verdict'], r.get('differs', ''), flush=True)
