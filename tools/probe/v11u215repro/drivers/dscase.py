#!/usr/bin/env python3
"""v11u215: downstream_uhdm2rtlil.one() on case dirs (dut.sv or args), $SLANG_UHDM the slang lane.
usage: dscase.py <workroot> <case dir>...   fail closed on the fence."""
import os, re, sys
fl = [l for l in open(os.path.join(os.environ['REPO'], 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')]
fenced = fl[0].split('=', 1)[1].strip().strip('"\'').split() if fl else []
if len(fenced) != 4: sys.exit('dscase: fence not 4 names')
sys.path.insert(0, os.path.join(os.environ.get('WT') or os.environ['REPO'], 'scripts'))
import downstream_uhdm2rtlil as ds
root = sys.argv[1]
for d in sys.argv[2:]:
    d = os.path.abspath(d)
    if any(re.search(r'\b%s\b' % re.escape(f), d) for f in fenced): sys.exit('dscase: fenced path refused')
    src = open(os.path.join(d, 'args')).read().split() if os.path.exists(os.path.join(d, 'args')) else ['dut.sv']
    name = os.path.basename(d)
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv'] + src, root, 300)
    print(os.path.relpath(d, os.environ.get('DSREL', '/tmp/v11u215_cases')), r, flush=True)
