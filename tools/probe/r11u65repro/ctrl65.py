#!/usr/bin/env python3
"""r11u65 PREDICTOR POSITIVE CONTROL — run predict65.py's own scan over each
grid arm's source and print the candidate net names it produces.  The control
passes when the scanner names every net the grid MOVES and is not silently
empty on an arm that moves."""
import importlib.util, os, sys
spec = importlib.util.spec_from_file_location('p', os.path.join(
    os.path.dirname(os.path.abspath(__file__)), 'predict65.py'))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
g = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'grid')
for arm in sorted(os.listdir(g)):
    p = os.path.join(g, arm, 'dut.sv')
    if not os.path.isfile(p):
        continue
    t = m.strip_comments(open(p, errors='replace').read())
    td, cand = set(), set()
    m.scan_text(t, td, cand)
    m.scan_uses(t, td, cand)
    print('CTRL %-18s typedefsWithDim=%s nets=%s' % (
        arm, ','.join(sorted(td)) or '-', ','.join(sorted(cand)) or '-'))
