#!/usr/bin/env python3
# (v11u227) dscase.py <workroot> <casedir>...: the downstream verdict of each case with $SLANG_UHDM
# (scripts/downstream_uhdm2rtlil.py `one`, the harness's own lanes). Fail-closed on $FENCED.
import os, re, sys
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscase: FENCED')
R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(R, 'scripts'))
import downstream_uhdm2rtlil as ds
W = os.path.abspath(sys.argv[1])
for c in sys.argv[2:]:
    c = os.path.abspath(c)
    if any(re.search(r'(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])' % re.escape(f), c) for f in F): sys.exit('fenced')
    n = os.path.basename(c)
    r = ds.one(n, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], os.path.join(W, os.path.basename(os.path.dirname(c))), 300)
    print(os.path.basename(os.path.dirname(c)) + '/' + n, r)
