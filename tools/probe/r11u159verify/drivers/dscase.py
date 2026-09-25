#!/usr/bin/env python3
"""dscase.py <state> <casedir>... : downstream verdict per case with the HEAD binary ($LAW) under a state:
ON (no switch), OWN (the case's own law switches, from its first line), ALLOFF (both landings off).
Uses the harness's own one() (Surelog lane = uhdm2rtlil's Surelog with the downstream flags).
Golden cache relocated to /tmp/r11u159_dsgold.  Fail-closed on $FENCED."""
import os, re, sys
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dscase.py: source drivers/env.sh first')
os.environ['GOLDEN_CACHE'] = '/tmp/r11u159_dsgold'
os.environ['SLANG_UHDM'] = os.environ['LAW']
sys.path.insert(0, '/tmp/wt_r11u159/scripts')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
spec = importlib.util.spec_from_file_location('grid', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid.py'))
SW = {}
for m in re.finditer(r"'(\w+)': '(R11[UV]\d+_\w+)'", open(spec.origin).read()): SW[m.group(1)] = m.group(2)
import downstream_uhdm2rtlil as ds
state = sys.argv[1]
ALL = {'R11U147_OFF': '1', 'R11U151_OFF': '1', 'R11U152_OFF': '1', 'R11V152_CLSVARNEW_OFF': '1', 'R11V147_GCABARE_OFF': '1'}
for d in sys.argv[2:]:
    d = os.path.abspath(d)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FENCED): print('FENCED-SKIP', d); continue
    rel = d.split('/r11u159verify/cases/')[1]
    laws = re.findall(r'§ (\w+)', open(f'{d}/dut.sv').readline())
    env = {}
    if state == 'OWN': env = {SW[l]: '1' for l in laws}
    if state == 'ALLOFF': env = dict(ALL)
    for k in list(SW.values()) + list(ALL): os.environ.pop(k, None)
    os.environ.update(env)
    w = f'/tmp/r11u159_dsc/{state}'
    r = ds.one(rel.replace('/', '__'), d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], w, 300)
    print(state, rel, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'] or '-', r['detail'][:80] or '-', sep=' | ', flush=True)
