#!/usr/bin/env python3
"""r11u66 CELL SCORER — the ELABORATED pattern-operand cells, encoding-AWARE.

Reads two uhdm-dump files through r11v61repro/shape.py's parser, keeps every
listing (the three uhdmtop* ELABORATED ones AND the three uhdmall*
DEFINITION ones, which ride as SHAPE controls) whose param_assign Rhs is an
op75, and scores it OPERAND BY OPERAND on the full cell
(kind, vpiSize, vpiConstType, the VALUE text) — a lister that prints only
vpiSize cannot see a UINT written where golden wrote an INT of the same width.

Rows are keyed by (listing, parameter name); a key golden has and the other
dump does not is MISSING, and a key only the other side has is EXTRA.  Both are
reported, never silently dropped.

usage: score66.py <golden.dump> <ours.dump> <armname>
exit 4 when the golden dump yields NO elaborated op75 row at all — a scorer
that reaches nothing can never read as agreement.
"""
import sys, os

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__))))
try:
    import shape
except ImportError:
    sys.stderr.write('score66.py needs shape.py beside it (copy it from '
                     'tools/probe/r11v61repro/shape.py)\n')
    raise

ELAB = ('uhdmtopModules', 'uhdmtopPackages', 'uhdmtopInterfaces',
        'uhdmallModules', 'uhdmallPackages', 'uhdmallInterfaces')


def rows(path):
    out = {}
    for sect, name, loc, d in shape.parse(path):
        if sect not in ELAB or not d.startswith('op=75 '):
            continue
        if name == '?':
            continue
        ops = d.split('ops=[', 1)[1].rstrip(']')
        out[(sect, name)] = ops.split()
    return out


def main():
    g, o, arm = sys.argv[1], sys.argv[2], sys.argv[3]
    G, O = rows(g), rows(o)
    if not G:
        sys.stderr.write('NO ELABORATED op75 ROW IN GOLDEN %s — scorer blind\n' % g)
        sys.exit(4)
    same = diff = missing = extra = 0
    for k in sorted(G):
        if k not in O:
            n = len(G[k])
            missing += n
            print('  MISSING %-16s %-30s %d cells  golden=[%s]'
                  % (k[0], k[1], n, ' '.join(G[k])))
            continue
        gc, oc = G[k], O[k]
        for i in range(max(len(gc), len(oc))):
            gv = gc[i] if i < len(gc) else '<none>'
            ov = oc[i] if i < len(oc) else '<none>'
            if gv == ov:
                same += 1
                print('  SAME %-16s %-28s op%-2d %s' % (k[0], k[1], i, gv))
            else:
                diff += 1
                print('  DIFF %-16s %-28s op%-2d golden=%-26s ours=%s'
                      % (k[0], k[1], i, gv, ov))
    for k in sorted(O):
        if k not in G:
            extra += len(O[k])
            print('  EXTRA %-16s %-30s ours=[%s]' % (k[0], k[1], ' '.join(O[k])))
    print('ARM %s SAME %d DIFF %d MISSING %d EXTRA %d'
          % (arm, same, diff, missing, extra))


if __name__ == '__main__':
    main()
