#!/usr/bin/env python3
# dscase.py <binary> <workroot> <casedir>... : the downstream harness's own one() on single-file cases (the brief's
# recipe: the Surelog lane with uhdm2rtlil's Surelog and the downstream flags, the slang lane with the translated
# command line); prints "<case> <verdict> <differs>".  Run with a fresh GOLDEN_CACHE.  Fenced paths refused.
import os, sys, re
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4:
    sys.exit('dscase: FENCED must hold the four names')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, FENCED)) + r')\b')
os.environ['SLANG_UHDM'] = sys.argv[1]
sys.path.insert(0, '/tmp/wt_r11u171/scripts')
import downstream_uhdm2rtlil as ds
wr = sys.argv[2]
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if fre.search(c):
        print(c, 'FENCED-REFUSED'); continue
    if not os.path.isfile(os.path.join(c, 'dut.sv')):
        continue
    name = c.split('/cases/')[-1].replace('/', '__')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    print(name, r if isinstance(r, str) else ' '.join(str(x) for x in (r if isinstance(r, (list, tuple)) else [r])))
    sys.stdout.flush()
