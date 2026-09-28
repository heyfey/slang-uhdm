#!/usr/bin/env python3
"""v11u216 (copied from r11u216repro/drivers/dsfaces.py): downstream verdicts (the gate's own one()) of this directory's cases with one binary.
usage: SLANG_UHDM=<bin> GOLDEN_CACHE=<dir> dsfaces.py <workroot> <case dir>... ; prints '<case> <verdict> <differs>'.
Fence: refuses a case path naming a fenced test (FENCED= line of r11u107repro/canaudit.sh; fail closed)."""
import sys, os, re
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
F = None
for l in open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')):
    if l.startswith('FENCED='): F = re.sub(r'["\']', '', l[len('FENCED='):]).split()
assert F and len(F) == 4, 'fence unreadable: refusing'
import downstream_uhdm2rtlil as ds
wr = sys.argv[1]
for c in sys.argv[2:]:
    c = os.path.abspath(c)
    assert not any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(x) + r'(?![A-Za-z0-9_])', c) for x in F), 'fenced'
    name = c.split('/cases/')[-1].replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(name, r.get('verdict'), r.get('surelog_status'), r.get('slang_status'), 'differs=' + str(r.get('differs')))
