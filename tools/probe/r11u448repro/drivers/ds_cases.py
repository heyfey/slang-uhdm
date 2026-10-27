#!/usr/bin/env python3
"""Downstream verdict of case dirs on one binary (SLANG_UHDM): scripts/downstream_uhdm2rtlil.one
per case dir, keyed on the full repro path.  usage: ds_cases.py <list of case dirs> <workroot> <out.tsv>"""
import os, sys
sys.path.insert(0, '/tmp/wt_r11u448/scripts')
import downstream_uhdm2rtlil as ds
lst, wr, out = sys.argv[1:4]
with open(out, 'w') as f:
    for c in [l.strip() for l in open(lst) if l.strip()]:
        c = os.path.abspath(c)
        key = c.split('/tools/probe/')[1].replace('/cases/', '/')
        r = ds.one(key.replace('/', '_'), c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'],
                   os.path.join(wr, key.replace('/', '_')), 300)
        f.write(f'{key}\t{r}\n'); f.flush()
