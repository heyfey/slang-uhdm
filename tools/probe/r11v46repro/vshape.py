#!/usr/bin/env python3
# v11u46 verifier SHAPE comparator: for every $signed/$unsigned sys_func_call in
# a uhdm-dump, extract its whole sub-block (the object line plus every following
# line more deeply indented), id-blind, and compare the two multisets.
# Also reports the PARENT line (the dump's back-ref) so a mis-parented call shows.
import re, sys, collections

HDR = re.compile(r'^(\s*)\\_sys_func_call: \(\$(signed|unsigned)\), ')

def blocks(path):
    lines = open(path, errors='replace').read().split('\n')
    out = collections.Counter()
    view = 'DEF'
    for i, ln in enumerate(lines):
        if '|uhdmtopModules:' in ln:
            view = 'ELAB'
        m = HDR.match(ln)
        if not m:
            continue
        ind = len(m.group(1))
        blk = [ln]
        j = i + 1
        while j < len(lines):
            t = lines[j]
            if t.strip() == '':
                break
            k = len(t) - len(t.lstrip())
            if k <= ind:
                break
            blk.append(t)
            j += 1
        txt = '\n'.join(blk)
        txt = re.sub(r', id:\d+', '', txt)
        txt = re.sub(r'\bid:\d+', '', txt)
        out[(view, txt)] += 1
    return out

g = blocks(sys.argv[1]); o = blocks(sys.argv[2])
gm = g - o; om = o - g
print("SHAPE-BLOCKS golden=%d ours=%d  golden-only=%d ours-only=%d" %
      (sum(g.values()), sum(o.values()), sum(gm.values()), sum(om.values())))
for (v, t), c in sorted(gm.items()):
    print("--- GOLDEN-ONLY x%d [%s]\n%s" % (c, v, t))
for (v, t), c in sorted(om.items()):
    print("--- OURS-ONLY   x%d [%s]\n%s" % (c, v, t))
