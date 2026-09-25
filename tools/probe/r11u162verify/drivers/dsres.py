#!/usr/bin/env python3
"""dsres.py <casedir>...: downstream verdict (the harness's one(), HEAD binary $LAW, no switch) of committed
cases of other passes (residue re-measure).  Golden cache /tmp/r11u162_dsgold.  Fail-closed on $FENCED."""
import os, re, sys
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dsres.py: source drivers/env.sh first')
os.environ['GOLDEN_CACHE'] = '/tmp/r11u162_dsgold'; os.environ['SLANG_UHDM'] = os.environ['LAW']
sys.path.insert(0, '/tmp/wt_r11u162/scripts')
import downstream_uhdm2rtlil as ds
for d in sys.argv[1:]:
    d = os.path.abspath(d)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FENCED): print('FENCED-SKIP', d); continue
    rel = d.split('/tools/probe/')[1]
    r = ds.one(rel.replace('/', '__'), d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/r11u162_dsc/RES', 300)
    print(rel, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'] or '-', sep=' | ', flush=True)
