#!/usr/bin/env python3
# v11u196: downstream verdict per case dir with the gate's own one(); SLANG_UHDM set by the caller BEFORE import.
# usage: SLANG_UHDM=<bin> GOLDEN_CACHE=<dir> ds.py <workroot> <case dir>...
import sys, os, re
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
F = [l for l in open(os.path.join(REPO, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')][0].split('=',1)[1].strip().strip('"\'').split()
assert len(F) == 4
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
assert ds.vg.SLANG_UHDM == os.environ['SLANG_UHDM'], ds.vg.SLANG_UHDM
wr = sys.argv[1]
for c in sys.argv[2:]:
    assert not any(re.search(r'\b%s\b' % re.escape(f), c) for f in F)
    name = os.path.relpath(c, os.path.join(REPO, 'tools/probe/v11u196repro/cases')).replace('/', '__')
    r = ds.one(name, os.path.abspath(c), ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print('\t'.join([os.path.basename(os.environ['SLANG_UHDM']), name, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'], r['detail'][:90]]), flush=True)
