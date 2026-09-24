#!/usr/bin/env python3
"""rows.py <workdir> [corpus...] — prints `corpus mode test golden ours` for
every row-mode of a sweep workdir whose cmds.txt names a golden and whose
slang.uhdm exists (tab-separated)."""
import glob, os, re, sys
wd = sys.argv[1]
corp = sys.argv[2:] or ['surelog', 'uhdm2rtlil']
for c in corp:
    for cm in sorted(glob.glob(os.path.join(wd, c, '*', '*', 'cmds.txt'))):
        d = os.path.dirname(cm)
        mode = os.path.basename(os.path.dirname(d))
        test = re.sub(r'-[0-9a-f]{8}$', '', os.path.basename(d))
        t = open(cm).read()
        m = re.search(r'golden cache hit (\S+?)\)', t)
        g = os.path.join(m.group(1), 'golden.uhdm') if m else None
        if not g:
            gl = glob.glob(os.path.join(d, '**', 'surelog.uhdm'), recursive=True)
            g = gl[0] if gl else None
        o = os.path.join(d, 'slang.uhdm')
        if g and os.path.exists(g) and os.path.exists(o):
            print('\t'.join([c, mode, test, g, o]))
