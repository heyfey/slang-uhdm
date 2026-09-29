#!/usr/bin/env python3
"""dsgrid.py <tag> <binary> <workroot> <case dir>... : the downstream harness's one() per case (Surelog lane with
uhdm2rtlil's Surelog and the downstream flags, slang lane with <binary>), 3 workers; prints
case verdict differs md5(slang nohier.il). Fail-closed on $FENCED."""
import os, sys, hashlib, glob
from concurrent.futures import ThreadPoolExecutor
fenced = os.environ.get('FENCED', '').split()
if len(fenced) != 4:
    sys.exit('dsgrid: source drivers/env.sh (FENCED)')
tag, binary, root = sys.argv[1], sys.argv[2], sys.argv[3]
os.environ['SLANG_UHDM'] = binary
repo = os.environ['REPO']
sys.path.insert(0, os.path.join(repo, 'scripts'))
import downstream_uhdm2rtlil as ds
def run(c):
    c = os.path.realpath(c)
    if any(n in c.split('/') for n in fenced):
        return c + ' REFUSED'
    name = c.split('/cases/')[-1].replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], os.path.join(root, tag), 300)
    h = '-'
    fs = glob.glob(os.path.join(root, tag, name, 'slang*', '*_nohier.il'))
    if fs:
        h = hashlib.md5(open(fs[0], 'rb').read()).hexdigest()[:8]
    return f"{name} {r['verdict']} differs={r['differs'] or '-'} nohier={h}"
with ThreadPoolExecutor(3) as ex:
    for line in ex.map(run, sys.argv[4:]):
        print(line, flush=True)
