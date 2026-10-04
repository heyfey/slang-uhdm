#!/usr/bin/env python3
# v11u235: ds.py <tag> <case dir>...: the downstream verdict of each case (scripts/downstream_uhdm2rtlil.py one()),
# SLANG_UHDM from the environment; run from the repository root. Refuses a fenced path.
import sys, os
sys.path.insert(0, 'scripts'); import downstream_uhdm2rtlil as ds
F = os.popen("grep -m1 '^FENCED=' tools/probe/r11u107repro/canaudit.sh").read().split('=',1)[-1].strip().strip('"\'').split()
if len(F) != 4: sys.exit('ds.py: FENCED not 4 names')
tag = sys.argv[1]
for c in sys.argv[2:]:
    if any(f in c.split('/') for f in F): sys.exit('ds.py: fenced path refused')
    src = 'dut.v' if os.path.exists(c + '/dut.v') else 'dut.sv'
    parts = ['-parse', '-nobuiltin', '-nocache'] + (['-sv'] if src == 'dut.sv' else []) + [src]
    r = ds.one(c.rstrip('/').split('/')[-1], os.path.abspath(c), parts, f'/tmp/v11u235_dsw_{tag}', 300)
    print(tag, c, r['verdict'], r['differs'])
