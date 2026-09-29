#!/usr/bin/env python3
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208) dsrow.py <state> <surelog corpus test>... : the downstream verdict of a SURELOG-corpus row (which has no
# lane in the downstream gate) through the harness's own one(), with the row's default-mode sources (its filelist or
# its dut.sv); states as dscase.py (ON = $LAW, ALLOFF = both landings off).  Golden cache /tmp/r11u221_dsgold.
# Refuses a fenced name (fail-closed on $FENCED).
import os, re, sys
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dsrow.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
from laws import SW, ALLOFF, OTHERS
os.environ['GOLDEN_CACHE'] = '/tmp/r11u221_dsgold'
state = sys.argv[1]
os.environ['SLANG_UHDM'] = os.environ['LAW']
for k in {s for v in SW.values() for s in v} | set(ALLOFF) | set(OTHERS): os.environ.pop(k, None)
if state == 'ALLOFF': os.environ.update({s: '1' for s in ALLOFF})
sys.path.insert(0, os.environ['R221_ROOT'] + '/scripts')
import downstream_uhdm2rtlil as ds
SR = os.environ['SURELOG_ROOT']
for t in sys.argv[2:]:
    if any(re.search(rf'\b{re.escape(n)}\b', t) for n in FENCED): print('FENCED-SKIP'); continue
    d = next((p for p in (f'{SR}/tests/{t}', f'{SR}/third_party/tests/{t}') if os.path.isdir(p)), None)
    if not d: print(t, 'NOT FOUND'); continue
    fl = f'{d}/filelist'
    files = open(fl).read().split() if os.path.exists(fl) else ['dut.sv']
    sv = ['-sv']
    if not os.path.exists(fl) and not os.path.exists(f'{d}/dut.sv') and os.path.exists(f'{d}/top.v'):
        files = ['top.v']; sv = []   # r11u213: a single Verilog-mode top.v (UnitElabBlock), as its .sl names it
    r = ds.one(t, d, ['-parse', '-nobuiltin', '-nocache'] + sv + files, f'/tmp/r11u221_dsr/{state}', 600)
    print(state, t, r['verdict'], r['surelog_status'], r['slang_status'], r['surelog_gates'], r['slang_gates'], r['differs'] or '-', (r['detail'] or '-')[:100], sep=' | ', flush=True)
