#!/usr/bin/env python3
"""downstream_cases.py <binary> <workroot> <casedir>...: the downstream verdict of each case
(the harness's own ds.one: uhdm2rtlil's Surelog lane vs the slang lane), one line per case."""
import os, sys
REPO = '/tmp/wt_v11u422'
sys.path.insert(0, os.path.join(REPO, 'scripts'))
os.environ['SLANG_UHDM'] = os.path.abspath(sys.argv[1])
import downstream_uhdm2rtlil as ds  # noqa: E402
wr = os.path.abspath(sys.argv[2])
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if not os.path.isfile(os.path.join(c, 'dut.sv')):
        continue
    name = os.path.basename(os.path.dirname(c)) + '_' + os.path.basename(c)
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(name, r['verdict'], r['differs'], r['surelog_gates'], r['slang_gates'], flush=True)
