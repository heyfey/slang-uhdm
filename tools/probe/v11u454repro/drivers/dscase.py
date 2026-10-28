#!/usr/bin/env python3
# dscase.py <binary> <workroot> <casedir>... : downstream verdict (uhdm2rtlil plugin) per case, slang lane = <binary>
import os, sys
os.environ['SLANG_UHDM'] = os.path.abspath(sys.argv[1])
sys.path.insert(0, '/home/heyfey/git-repos/slang-uhdm/scripts')
import downstream_uhdm2rtlil as ds
work = sys.argv[2]
os.makedirs(work, exist_ok=True)
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if not os.path.isdir(c):
        continue
    name = c.rstrip('/').split('/cases/')[-1].replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], os.path.join(work, name), 300)
    print(c.split('/cases/')[-1], r)
