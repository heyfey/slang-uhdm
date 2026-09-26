#!/usr/bin/env python3
# dscase.py <bin> <out.tsv> <casedir>... : downstream verdict of each single-file case via the harness's own one()
import sys, os, re
os.environ['SLANG_UHDM'] = sys.argv[1]
os.environ.setdefault('GOLDEN_CACHE', '/tmp/v11u171_dsgold')
fen = os.environ['FENCED'].split()
assert len(fen) == 4
sys.path.insert(0, '/tmp/wt_v11u171/scripts')
import downstream_uhdm2rtlil as ds
out = open(sys.argv[2], 'w')
tag = os.path.basename(sys.argv[1]).split('.')[0]
for d in sys.argv[3:]:
    d = os.path.abspath(d)
    if any(re.search(r'\b%s\b' % f, d) for f in fen):
        print('FENCED refused', d); continue
    if os.path.exists(os.path.join(d, 'files')):
        continue
    name = d.split('/v11u171_cases/')[-1].replace('/', '_')
    row = ds.one(name, d, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], '/tmp/v11u171_dsw_' + tag, 300)
    out.write('%s\t%s\n' % (name, row)); out.flush()
