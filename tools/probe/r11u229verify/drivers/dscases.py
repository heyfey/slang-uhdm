#!/usr/bin/env python3
# (r11u229: copied from r11u226verify/drivers/dscases.py, which adapted r11u223repro's: a switch state, the case's own file list, a pool, lane md5s.)
"""dscases.py <binary> <workroot> <state> <case dir>...: the downstream verdict (scripts/downstream_uhdm2rtlil.py's own
one()) of every case dir with SLANG_UHDM=<binary> under the switch state <state> (`on`, or ENV=1 words joined by `+`);
the golden cache under $GOLDEN_CACHE (the caller sets a fresh one).  Prints: rel state verdict differs md5(slang
nohier.il) md5(surelog nohier.il).  Fail-closed on $FENCED: a path holding a fenced name is refused."""
import os, sys, re, glob, hashlib
from concurrent.futures import ThreadPoolExecutor
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('dscases.py: source drivers/env.sh first')
if not os.environ.get('GOLDEN_CACHE'): sys.exit('dscases.py: export a fresh GOLDEN_CACHE')
b, root, state = sys.argv[1:4]
if not os.access(b, os.X_OK): sys.exit(f'dscases.py: {b} not executable')
os.environ['SLANG_UHDM'] = b
if state != 'on':
    for w in state.split('+'): os.environ[w.split('=')[0]] = '1'
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds
def md5(p):
    try: return hashlib.md5(open(p, 'rb').read()).hexdigest()[:10]
    except Exception: return '-'
def job(c):
    c = os.path.abspath(c)
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', c) for f in F): return f'{c} FENCED refused'
    rel = re.sub(r'^r11u229verify/cases/', '', re.sub(r'^.*/tools/probe/', '', c))
    name = re.sub(r'[^A-Za-z0-9_]', '_', rel)
    files = open(f'{c}/args').read().split() if os.path.exists(f'{c}/args') else ['dut.sv']
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv'] + files, root, 300)
    w = os.path.join(root, name)
    gn = sorted(glob.glob(f'{w}/**/slang*/*_nohier.il', recursive=True)) or sorted(glob.glob(f'{w}/**/*slang*nohier*.il', recursive=True))
    sn = sorted(glob.glob(f'{w}/**/surelog*/*_nohier.il', recursive=True)) or sorted(glob.glob(f'{w}/**/*surelog*nohier*.il', recursive=True))
    return f"{rel} {state} {r.get('verdict')} differs={r.get('differs') or '-'} slang={md5(gn[0]) if gn else '-'} surelog={md5(sn[0]) if sn else '-'}"
with ThreadPoolExecutor(int(os.environ.get('P', '3'))) as ex:
    for line in ex.map(job, sys.argv[4:]): print(line, flush=True)
