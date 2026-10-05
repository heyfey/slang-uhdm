#!/usr/bin/env python3
# (v11u244) ds.py <casesroot> <workroot> <tag>: the downstream verdict (scripts/downstream_uhdm2rtlil.py one()) of every
# case under <casesroot>/*/* with $SLANG_UHDM; one csv line per case: tag,case,verdict,differs,detail. Fail-closed on
# the fence: a case path holding a fenced name is refused.
import os, sys, re
here = os.path.dirname(os.path.abspath(__file__))
repo = os.path.abspath(os.path.join(here, '..', '..', '..', '..'))
fl = [l for l in open(os.path.join(repo, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')]
fenced = fl[0].split('=', 1)[1].strip().strip('"\'').split() if fl else []
if len(fenced) != 4: sys.exit('ds.py: fence unreadable')
sys.path.insert(0, os.path.join(repo, 'scripts'))
import downstream_uhdm2rtlil as ds
root, work, tag = sys.argv[1], sys.argv[2], sys.argv[3]
for c in sorted(d for d in (os.path.join(a, b) for a in os.listdir(root) for b in os.listdir(os.path.join(root, a)))):
    if any(re.search(r'\b%s\b' % re.escape(f), c) for f in fenced): sys.exit('ds.py: fenced path refused')
    d = os.path.join(root, c)
    r = ds.one(c.replace('/', '_'), d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], work, 300)
    print(f"{tag},{c},{r['verdict']},{r['differs']},{r['detail']}", flush=True)
