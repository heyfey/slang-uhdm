#!/usr/bin/env python3
# v11u285 ds.py <binary> <workroot> <casedir>...: the downstream verdict of each case dir with the HEAD harness's
# one() (scripts/downstream_uhdm2rtlil.py: the Surelog lane with uhdm2rtlil's Surelog and the downstream flags, the
# slang lane with the translated command line). Fail-closed on $FENCED; a fenced path is refused.
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('ds.py: FENCED unset')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
if not os.access(sys.argv[1], os.X_OK): sys.exit('ds.py: binary not executable')
os.environ['SLANG_UHDM'] = sys.argv[1]
import downstream_uhdm2rtlil as ds
wr = sys.argv[2]
for c in sys.argv[3:]:
    if any(re.search(r'(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])' % re.escape(f), c) for f in F): sys.exit('ds.py: fenced path refused')
    name = c.rstrip('/').split('/cases/')[-1].replace('/', '__')
    r = ds.one(name, os.path.abspath(c), ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(name, r['verdict'], r['differs'], r['surelog_status'], r['slang_status'])
