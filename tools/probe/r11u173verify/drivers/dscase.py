#!/usr/bin/env python3
"""dscase.py <state> <casedir>... : the downstream verdict of a case with the HEAD binary ($LAW) under a state:
ON (no switch), OWN (the case's own law switches from its first line; a refinement's parent law too, i.e. that
site's pristine), ALLOFF (the three landings off), FIX ($FIX binary, no switch).  The harness's own one() (Surelog
lane = uhdm2rtlil's Surelog with the downstream flags; slang lane = the translated command line), golden cache
relocated to /tmp/r11u173_dsgold.  Prints verdict, both statuses, the differing files.  Fail-closed on $FENCED."""
import os, re, sys
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dscase.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
from laws import SW, PARENT, ALLOFF
os.environ['GOLDEN_CACHE'] = '/tmp/r11u173_dsgold'
state = sys.argv[1]
os.environ['SLANG_UHDM'] = os.environ['FIX'] if state == 'FIX' else os.environ['LAW']
sys.path.insert(0, '/tmp/wt_r11u173/scripts')
import downstream_uhdm2rtlil as ds
KEYS = {s for v in SW.values() for s in v} | set(ALLOFF)
for d in sys.argv[2:]:
    d = os.path.abspath(d)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FENCED): print('FENCED-SKIP', d); continue
    rel = d.split('/r11u173verify/cases/')[1]
    laws = re.findall(r'§ (\w+)', open(f'{d}/dut.sv').readline())
    laws += [PARENT[l] for l in laws if l in PARENT]
    env = {}
    if state == 'OWN': env = {s: '1' for l in laws for s in SW[l]}
    if state == 'ALLOFF': env = {s: '1' for s in ALLOFF}
    for k in KEYS: os.environ.pop(k, None)
    os.environ.update(env)
    w = f'/tmp/r11u173_dsc/{state}'
    r = ds.one(rel.replace('/', '__'), d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], w, 300)
    print(state, rel, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'] or '-', (r['detail'] or '-')[:80], sep=' | ', flush=True)
