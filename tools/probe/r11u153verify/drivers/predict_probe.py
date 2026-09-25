#!/usr/bin/env python3
# predict_probe.py <out.tsv>: predict.py's four faces over every tests/probe case (its dut.sv and siblings).
import sys, os, glob, importlib.util
os.environ.setdefault('FENCED', '')
spec = importlib.util.spec_from_file_location('p', os.path.dirname(os.path.abspath(__file__)) + '/predict.py')
src = open(spec.origin).read()
rx_src = src[src.index('RX = {'):src.index('MEMO = {}')]
import re
RX = {}; exec(rx_src)
root = '/tmp/wt_r11u153/tests/probe'
n = 0
with open(sys.argv[1], 'w') as fo:
    for d in sorted(glob.glob(root + '/**/dut.sv', recursive=True)):
        cd = os.path.dirname(d); t = ''
        for f in glob.glob(cd + '/*'):
            if f.endswith(('.sv', '.v', '.svh', '.vh', '.inc')): t += open(f, errors='replace').read()
        laws = [k for k, rs in RX.items() if all(r.search(t) for r in rs)]
        if laws: n += 1
        fo.write(os.path.relpath(cd, root) + '\t' + ','.join(laws) + '\n')
print(n, 'probe cases carry a face')
