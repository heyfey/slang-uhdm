#!/usr/bin/env python3
"""r10uvm98 — MEASUREMENT-ONLY multiset join of two ct98cen censuses.

  join98.py <tag> <golden.cen> <ours.cen> [--cells <file>] [--field DEFN|TSNAME|ALIAS|INST|ALL]

Key   = (SITE, OWNER).  Value = (TSNAME, DEFN, ALIAS, INST) or, with --field,
that ONE field alone — the head this pass is chasing is `Class_defn` (DEFN),
the LAST field of `class_typespec::Compare`, and the other three are separate,
pre-existing families (R1 = INST) that must not drown it.

A MULTISET join (keys legitimately repeat: the DEF and ELAB copies of one
class).  LHS is ALWAYS golden.
"""
import sys, collections

IDX = {'TSNAME': 0, 'DEFN': 1, 'ALIAS': 2, 'INST': 3}

def load(p, field):
    m = collections.defaultdict(collections.Counter)
    with open(p) as f:
        for line in f:
            t = line.rstrip('\n').split('\t')
            if len(t) != 6:
                continue
            v = (t[2], t[3], t[4], t[5])
            m[(t[0], t[1])][v if field == 'ALL' else v[IDX[field]]] += 1
    return m

def main():
    tag, gp, op = sys.argv[1], sys.argv[2], sys.argv[3]
    cells = None
    field = 'ALL'
    if '--cells' in sys.argv:
        cells = open(sys.argv[sys.argv.index('--cells') + 1], 'a')
    if '--field' in sys.argv:
        field = sys.argv[sys.argv.index('--field') + 1]
    g, o = load(gp, field), load(op, field)
    same = diff = gonly = oonly = 0
    for k in sorted(set(g) | set(o)):
        gv, ov = g.get(k, collections.Counter()), o.get(k, collections.Counter())
        if not ov:
            gonly += sum(gv.values()); continue
        if not gv:
            oonly += sum(ov.values()); continue
        inter = gv & ov
        same += sum(inter.values())
        gl, ol = gv - inter, ov - inter
        d = max(sum(gl.values()), sum(ol.values()))
        diff += d
        if d and cells:
            cells.write('%s\tDIFF\t%s\t%s\tG=%s\tO=%s\n' %
                        (tag, k[0], k[1], sorted(gl.elements()), sorted(ol.elements())))
    print('%-40s field=%-6s same %-7d DIFF %-6d GOLDEN-ONLY-KEY %-6d OURS-ONLY-KEY %d' %
          (tag, field, same, diff, gonly, oonly))

main()
