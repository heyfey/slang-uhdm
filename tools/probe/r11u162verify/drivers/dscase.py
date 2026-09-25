#!/usr/bin/env python3
"""dscase.py <state> <casedir>... : downstream verdict per case with the HEAD binary ($LAW) under a state:
ON (no switch), OWN (the case's own law switches, from its first line; a refinement's parent law too, i.e.
pristine), ALLOFF (both landings off).  The harness's own one() (Surelog lane = uhdm2rtlil's Surelog with
the downstream flags; slang lane = the translated command line).  Golden cache relocated to
/tmp/r11u162_dsgold.  Fail-closed on $FENCED."""
import os, re, sys, importlib.util
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dscase.py: source drivers/env.sh first')
os.environ['GOLDEN_CACHE'] = '/tmp/r11u162_dsgold'
os.environ['SLANG_UHDM'] = os.environ['LAW']
sys.path.insert(0, '/tmp/wt_r11u162/scripts')
D = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(D, 'grid.py')).read()
ns = {}
exec(src[src.index('SW = {'):src.index("ALL = [")], ns)
SW, PARENT = ns['SW'], ns['PARENT']
import downstream_uhdm2rtlil as ds
state = sys.argv[1]
ALL = {'R11U154_OFF': '1', 'R11V154_VIDMOD_OFF': '1', 'R11U155_OFF': '1'}
KEYS = {s for v in SW.values() for s in v} | set(ALL)
for d in sys.argv[2:]:
    d = os.path.abspath(d)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FENCED): print('FENCED-SKIP', d); continue
    rel = d.split('/r11u162verify/cases/')[1]
    laws = re.findall(r'§ (\w+)', open(f'{d}/dut.sv').readline())
    laws += [PARENT[l] for l in laws if l in PARENT]
    env = {}
    if state == 'OWN': env = {s: '1' for l in laws for s in SW[l]}
    if state == 'ALLOFF': env = dict(ALL)
    for k in KEYS: os.environ.pop(k, None)
    os.environ.update(env)
    w = f'/tmp/r11u162_dsc/{state}' + os.environ.get('DSTAG', '')
    r = ds.one(rel.replace('/', '__'), d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], w, 300)
    print(state, rel, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'] or '-', (r['detail'] or '-')[:80], sep=' | ', flush=True)
