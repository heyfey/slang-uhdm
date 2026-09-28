#!/usr/bin/env python3
"""v11u206: the downstream gate's one() on case dirs with $SLANG_UHDM. usage: dscase.py <workroot> <casedir>... (fence fail-closed)"""
import os, re, sys
repo = '/home/heyfey/git-repos/slang-uhdm'
fl = [l for l in open(os.path.join(repo, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')]
if not fl: sys.exit('fence unreadable')
fenced = fl[0].split('=', 1)[1].strip().strip('"\'').split()
if len(fenced) != 4: sys.exit('fence not 4 names')
sys.path.insert(0, os.path.join(repo, 'scripts'))
import downstream_uhdm2rtlil as ds
root = sys.argv[1]
for d in sys.argv[2:]:
    d = os.path.abspath(d)
    if any(re.search(r'\b%s\b' % re.escape(f), d) for f in fenced): sys.exit('fenced path refused')
    name = d.replace('/tmp/v11u206_cases/', '').replace('/home/heyfey/git-repos/slang-uhdm/tools/probe/', '').replace('/', '_')
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], root, 300)
    print(name, r.get('verdict'), r.get('differs', '') or '-', r.get('slang_status', '') or '-', flush=True)
