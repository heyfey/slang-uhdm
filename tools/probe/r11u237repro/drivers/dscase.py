#!/usr/bin/env python3
# r11u237: dscase.py <binary> <workroot> <list of case dirs> : the downstream lane (scripts/downstream_uhdm2rtlil.py
# one(): Surelog lane with the downstream flags, slang lane the translated command line) on every .sv case of the
# list, 3 at a time; prints "<case> <verdict> differs=<..>". SLANG_UHDM is set to the binary before the harness is
# imported. Fail-closed on $FENCED: a fenced path is refused. Paths resolve from this checkout.
import os, re, sys, concurrent.futures
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscase.py: FENCED unset (source drivers/env.sh)')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, F)) + r')\b')
b, wr, lst = sys.argv[1:4]
if not os.access(b, os.X_OK): sys.exit('dscase.py: binary not executable')
os.environ['SLANG_UHDM'] = b
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
cases = [l.strip() for l in open(lst) if l.strip()]
cases = [c for c in cases if not fre.search(c) and os.path.isfile(os.path.join(c, 'dut.sv'))]
def run(c):
    name = re.sub(r'.*/cases/', '', c).replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], wr, 300)
    return f"{name} {r.get('verdict')} differs={r.get('differs','')}"
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    for l in ex.map(run, cases): print(l, flush=True)
