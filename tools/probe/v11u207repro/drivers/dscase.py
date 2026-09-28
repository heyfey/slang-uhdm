#!/usr/bin/env python3
"""v11u207: the downstream gate's own one() on case dirs, $SLANG_UHDM the slang lane.  A case with an `args` file
lists its root files, a `nosv` file drops -sv.  usage: dscase.py <workroot> <case dir>...  (fence fail-closed)"""
import os, re, sys, subprocess
here = os.path.dirname(os.path.abspath(__file__))
repo = os.path.dirname(subprocess.run(["git", "-C", here, "rev-parse", "--path-format=absolute", "--git-common-dir"],
                                      capture_output=True, text=True).stdout.strip())
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
    src = open(os.path.join(d, 'args')).read().split() if os.path.exists(os.path.join(d, 'args')) else ['dut.sv']
    sv = [] if os.path.exists(os.path.join(d, 'nosv')) else ['-sv']
    name = '_'.join(d.split('/')[-2:])
    r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache'] + sv + src, root, 300)
    print(name, r, flush=True)
