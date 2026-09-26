#!/usr/bin/env python3
"""dsrow.py <state> <name> <dir> <arg>...: the downstream verdict (the harness's own one(): uhdm2rtlil's Surelog with
the downstream flags vs slang-uhdm's translated command line, Yosys + the plugin, nohier / il / synth compared) of a
SURELOG-corpus test the landings converted, which the downstream gate does not run (it runs uhdm2rtlil tests only).
State ON = $LAW, ALLOFF = $LAW under both landings' switches.  Prints the verdict and the md5 of the slang lane's
three netlists.  Fail-closed on $FENCED (refuses a fenced name or directory)."""
import os, re, sys, hashlib, glob
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dsrow.py: source drivers/env.sh first')
st, name, d = sys.argv[1:4]; args = sys.argv[4:]
if any(re.search(rf'\b{re.escape(f)}\b', name + ' ' + d) for f in FENCED): sys.exit('dsrow.py: fenced refused')
D = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, D)
from laws import ALLOFF
os.environ['GOLDEN_CACHE'] = '/tmp/r11u182_dsgold'
os.environ['SLANG_UHDM'] = os.environ['LAW']
for k in ALLOFF: os.environ.pop(k, None)
if st == 'ALLOFF': os.environ.update({k: '1' for k in ALLOFF})
if st == 'FIX': os.environ['SLANG_UHDM'] = os.environ['FIX']
sys.path.insert(0, '/tmp/wt_r11u182/scripts')
import downstream_uhdm2rtlil as ds
w = f'/tmp/r11u182_dsrow/{st}'
r = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache'] + args, w, 900)
def m(p): return hashlib.md5(open(p, 'rb').read()).hexdigest()[:10] if os.path.exists(p) else '-'
fs = sorted(glob.glob(f'{w}/{name}/**/*', recursive=True))
sl = [p for p in fs if '/slang' in p and p.endswith(('_nohier.il', '.il', '_synth.v'))]
su = [p for p in fs if '/surelog' in p and p.endswith(('_nohier.il', '.il', '_synth.v'))]
print(st, name, r['verdict'], r['surelog_status'], r['slang_status'], r['surelog_gates'], r['slang_gates'], r['differs'] or '-',
      'slang:' + ','.join(os.path.basename(p) + '=' + m(p) for p in sl), 'surelog:' + ','.join(os.path.basename(p) + '=' + m(p) for p in su), flush=True)
