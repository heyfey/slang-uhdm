#!/usr/bin/env python3
"""(copy of r11u161gen/drivers/dscase.py) dscase.py <tag> <binary> <casedir>... [-- ENV=VAL ...]: downstream verdict per case (the harness's one():
Surelog lane = uhdm2rtlil's Surelog with the downstream flags, slang lane = the translated command line).
Golden cache relocated to /tmp/v11u164_dsgold.  Fail-closed on $FENCED."""
import os, re, sys
FENCED = os.environ.get('FENCED', '').split()
if len(FENCED) != 4: sys.exit('dscase.py: source drivers/env.sh first')
os.environ['GOLDEN_CACHE'] = '/tmp/v11u164_dsgold'
args = sys.argv[1:]; env = {}
if '--' in args:
    i = args.index('--'); env = dict(a.split('=', 1) for a in args[i+1:]); args = args[:i]
tag, binary, dirs = args[0], args[1], args[2:]
os.environ['SLANG_UHDM'] = os.path.abspath(binary)
os.environ.update(env)
sys.path.insert(0, '/tmp/wt_v11u164pris/scripts')
import downstream_uhdm2rtlil as ds
for d in dirs:
    d = os.path.abspath(d)
    if any(re.search(rf'\b{re.escape(n)}\b', d) for n in FENCED): print('FENCED-SKIP', d); continue
    rel = re.sub(r'.*/(tools/probe/|v11u164_cases/)', '', d)
    w = f'/tmp/v11u164_dsc/{tag}'
    r = ds.one(rel.replace('/', '__'), d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], w, 300)
    print(tag, rel, r['verdict'], r['surelog_status'], r['slang_status'], r['differs'] or '-', (r['detail'] or '-')[:80], sep=' | ', flush=True)
