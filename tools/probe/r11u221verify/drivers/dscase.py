#!/usr/bin/env python3
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: copied from r11u190verify/drivers, paths renamed; the landings under test are passes 184 and 186.)
"""dscase.py <state> <casedir>... : the downstream verdict of a case through the harness's own one() (Surelog lane =
uhdm2rtlil's Surelog with the downstream flags; slang lane = the translated command line), golden cache relocated to
/tmp/r11u221_dsgold.  States on the HEAD binary ($LAW): ON (no switch), ALLOFF (both landings off), OWN (the case's
own law switches from its first line), FIX ($FIX, no switch).  A dut.v case runs without -sv; an `args` case lists
its root files.  Prints verdict, both statuses, gates and the differing files.  Fail-closed on $FENCED."""
import os, re, sys
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dscase.py: source drivers/env.sh first')
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
from laws import SW, PARENT, ALLOFF, OTHERS
os.environ['GOLDEN_CACHE'] = '/tmp/r11u221_dsgold'
state = sys.argv[1]
os.environ['SLANG_UHDM'] = os.environ['FIX'] if state == 'FIX' else os.environ['LAW']
sys.path.insert(0, os.environ['R221_ROOT'] + '/scripts')
import downstream_uhdm2rtlil as ds
KEYS = {s for v in SW.values() for s in v} | set(ALLOFF) | set(OTHERS)
for d in sys.argv[2:]:
    d = os.path.abspath(d)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FENCED): print('FENCED-SKIP', d); continue
    rel = d.split('/r11u221verify/cases/')[1] if '/r11u221verify/cases/' in d else 'tp/' + d.split('/tools/probe/')[1]
    src = 'dut.sv' if os.path.exists(f'{d}/dut.sv') else 'dut.v'
    files = open(f'{d}/args').read().split() if os.path.exists(f'{d}/args') else (open(f'{d}/files').read().split() if os.path.exists(f'{d}/files') else [src])
    first = files[0] if os.path.exists(f'{d}/args') else src   # r11u213: an args case names its laws in its first file
    sv = (src == 'dut.sv' or os.path.exists(f'{d}/args')) and not os.path.exists(f'{d}/nosv')   # r11u213: case.sh's rule
    laws = re.findall(r'§ (\w+)', open(f'{d}/{first}').readline())
    laws += [PARENT[l] for l in laws if l in PARENT]
    env = {}
    if state == 'OWN': env = {s: '1' for l in laws for s in SW.get(l, [])}
    if state == 'ALLOFF': env = {s: '1' for s in ALLOFF}
    for k in KEYS: os.environ.pop(k, None)
    os.environ.update(env)
    w = f'/tmp/r11u221_dsc/{state}'
    parts = ['-parse', '-nobuiltin', '-nocache'] + (['-sv'] if sv else []) + files
    r = ds.one(rel.replace('/', '__'), d, parts, w, 300)
    print(state, rel, r['verdict'], r['surelog_status'], r['slang_status'], r['surelog_gates'], r['slang_gates'], r['differs'] or '-', (r['detail'] or '-')[:80], sep=' | ', flush=True)
