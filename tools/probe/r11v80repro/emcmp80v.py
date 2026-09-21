#!/usr/bin/env python3
"""r11v80 (verifier) — THE ELEMENT-LEVEL CONVERSION / REGRESSION LEDGER.

For every array holder slot in a dump section, classify the patched binary's
reading against golden AND against the pristine one:

    CONVERTED     pristine disagreed with golden, patched agrees
    MOVED-WRONG   pristine agreed with golden, patched does not  (a REGRESSION)
    STILL-WRONG   both disagree and the patched text CHANGED
                  (a newly written object whose COMPARED fields are not
                  golden's — the class pass 77's law refuses)
    PRE-EXISTING  both disagree and nothing changed

usage: emcmp80v.py <grid-dir> <arm> <section> <patched-tag>
       (reads <grid>/<arm>/{gold,ours.pris,ours.<tag>}.dump)
"""
import os
import subprocess
import sys

ELEM = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'elem80v.py')
grid, arm, sect, ftag = sys.argv[1:5]


def run(fn):
    return subprocess.run(
        ['python3', ELEM, '%s/%s/%s' % (grid, arm, fn), sect],
        capture_output=True, text=True).stdout.splitlines()


g, p, f = {}, {}, {}
for d, fn in ((g, 'gold.dump'), (p, 'ours.pris.dump'),
              (f, 'ours.%s.dump' % ftag)):
    for l in run(fn):
        d.setdefault(l.split()[0], []).append(l)

for k in sorted(set(g) | set(p) | set(f)):
    gg, pp, ff = sorted(g.get(k, [])), sorted(p.get(k, [])), sorted(f.get(k, []))
    if gg == ff:
        if pp != ff:
            print("CONVERTED    %s %s" % (arm, k))
        continue
    tag = ("MOVED-WRONG" if gg == pp else
           ("STILL-WRONG" if pp != ff else "PRE-EXISTING"))
    print("%s %s %s" % (tag, arm, k))
    print("   G", gg or ['<NONE>'])
    print("   P", pp or ['<NONE>'])
    print("   F", ff or ['<NONE>'])
