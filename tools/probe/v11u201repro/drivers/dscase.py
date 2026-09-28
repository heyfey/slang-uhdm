#!/usr/bin/env python3
"""v11u201: the downstream gate's own one() on case dirs (dut.sv), $SLANG_UHDM the slang lane.
usage: dscase.py <workroot> <case dir>...   (fail closed on the fence)"""
import os, re, sys
import subprocess
here = os.path.dirname(os.path.abspath(__file__))
repo = os.path.dirname(subprocess.run(['git', '-C', here, 'rev-parse', '--path-format=absolute', '--git-common-dir'], capture_output=True, text=True).stdout.strip())
fl = [l for l in open(os.path.join(repo, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')]
if not fl: sys.exit('dscase: fence unreadable')
fenced = fl[0].split('=', 1)[1].strip().strip('"\'').split()
if len(fenced) != 4: sys.exit('dscase: fence not 4 names')
sys.path.insert(0, os.path.join(repo, 'scripts'))
import downstream_uhdm2rtlil as ds
root = sys.argv[1]
for d in sys.argv[2:]:
    d = os.path.abspath(d)
    if any(re.search(r'\b%s\b' % re.escape(f), d) for f in fenced): sys.exit('dscase: fenced path refused')
    name = d.split('/')[-2] + '_' + os.path.basename(d)
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], root, 300)
    print(name, r['verdict'], r['differs'], r['slang_status'], flush=True)
