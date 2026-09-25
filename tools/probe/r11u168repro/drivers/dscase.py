#!/usr/bin/env python3
"""dscase.py <cases root> <workroot> <out.tsv>: the downstream harness's own one() on every case (dut.sv / dut.v /
args), with the binary in $SLANG_UHDM and a FRESH GOLDEN_CACHE (the cache keys on directory + arguments, not content).
Prints case, verdict, differs."""
import os, sys, glob
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'scripts'))
import downstream_uhdm2rtlil as ds
root, work, out = sys.argv[1:4]
rows = []
for d in sorted(set(os.path.dirname(p) for p in glob.glob(root + '/*/*/dut.sv') + glob.glob(root + '/*/*/dut.v'))):
    rel = os.path.relpath(d, root)
    if os.path.isfile(d + '/args'):
        srcs = open(d + '/args').read().split()
    else:
        srcs = ['dut.sv'] if os.path.isfile(d + '/dut.sv') else ['dut.v']
    parts = ['-parse', '-nobuiltin', '-nocache'] + (['-sv'] if srcs == ['dut.sv'] else []) + srcs
    r = ds.one(rel.replace('/', '_'), d, parts, work, 300)
    rows.append((rel, r['verdict'], r.get('differs', '')))
with open(out, 'w') as f:
    for r in rows:
        f.write('\t'.join(r) + '\n')
print(out, len(rows))
