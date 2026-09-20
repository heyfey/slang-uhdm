#!/usr/bin/env python3
"""r11u68 THREE-WAY CELL SCORER — golden vs PRISTINE vs LAW, per elaborated
pattern operand, in THREE projections.

  FULL  the whole cell (kind + vpiSize + vpiConstType + the VALUE text)
  SIZE  the vpiSize alone -- THE HALF THIS PASS'S LAW A OWNS
  ENC   vpiConstType + the VALUE alone -- the landed encoding laws' half,
        which rides here as a CONTROL and must show TO 0 / AWAY 0 / MOVED 0

verdicts per projection:
  TO           wrong on pristine, RIGHT on the law binary
  AWAY         RIGHT on pristine, wrong on the law binary      <- must be 0
  MOVED-WRONG  wrong on both AND the law changed it            <- must be 0
  STILL        wrong on both, the law did not touch it
  SAME         right on both

usage: cmp68.py <golden.dump> <pristine.dump> <law.dump> <armname>
exit 4 when golden yields no elaborated op75 row (a blind scorer).
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape68 as shape

ELAB = ('uhdmtopModules', 'uhdmtopPackages', 'uhdmtopInterfaces',
        'uhdmallModules', 'uhdmallPackages', 'uhdmallInterfaces')


def rows(path):
    out = {}
    for sect, name, loc, d in shape.parse(path):
        if sect not in ELAB or not d.startswith('op=75 ') or name == '?':
            continue
        if 'ops=[' not in d:
            continue
        out[(sect, name)] = d.split('ops=[', 1)[1].rstrip(']').split()
    return out


def enc(cell):
    if not cell.startswith('const/'):
        return cell
    rest = cell[len('const/'):]
    return 'const@' + rest.split('@', 1)[1] if '@' in rest else cell


def size(cell):
    if not cell.startswith('const/'):
        return cell
    return 'const/' + cell[len('const/'):].split('@', 1)[0]


def score(g, p, l, proj):
    t = {'TO': 0, 'AWAY': 0, 'MOVED-WRONG': 0, 'STILL': 0, 'SAME': 0}
    lines = []
    shape_bad = []
    for k in sorted(g):
        gc, pc, lc = g[k], p.get(k), l.get(k)
        if pc is None and lc is None:
            continue
        pc, lc = pc or [], lc or []
        # THE ALIGNMENT TRAP.  Some rows carry a PRE-EXISTING shape residue —
        # our walk emits no operand at all for an `'x`/`'z` setter — so the
        # operand lists have different LENGTHS and an index join compares
        # unrelated cells (it manufactured two phantom MOVED-WRONGs on
        # `e1_enc56`).  Such a row is reported as SHAPE-MISMATCH and scored in
        # neither direction; the residue is named in the write-up instead.
        if len(pc) != len(gc) or len(lc) != len(gc):
            shape_bad.append('  SHAPE-MISMATCH %-16s %-26s golden=%d pris=%d law=%d'
                             % (k[0], k[1], len(gc), len(pc), len(lc)))
            continue
        for i in range(len(gc)):
            gv = proj(gc[i])
            pv = proj(pc[i]) if i < len(pc) else '<none>'
            lv = proj(lc[i]) if i < len(lc) else '<none>'
            if pv == gv and lv == gv:
                v = 'SAME'
            elif pv != gv and lv == gv:
                v = 'TO'
            elif pv == gv and lv != gv:
                v = 'AWAY'
            elif pv == lv:
                v = 'STILL'
            else:
                v = 'MOVED-WRONG'
            t[v] += 1
            if v not in ('SAME', 'STILL'):
                lines.append('  %-11s %-16s %-26s op%-2d golden=%-26s pris=%-26s law=%s'
                             % (v, k[0], k[1], i, gv, pv, lv))
    return t, lines + shape_bad


def main():
    gp, pp, lp, arm = sys.argv[1:5]
    g, p, l = rows(gp), rows(pp), rows(lp)
    if not g:
        sys.stderr.write('NO ELABORATED op75 ROW IN GOLDEN %s — scorer blind\n' % gp)
        sys.exit(4)
    absent = sum(len(v) for k, v in g.items() if k not in p and k not in l)
    for label, proj in (('SIZE', size), ('ENC', enc), ('FULL', lambda c: c)):
        t, lines = score(g, p, l, proj)
        print('-- %s %s' % (arm, label))
        for ln in lines:
            print(ln)
        print('ARM %s %s TO %d AWAY %d MOVED-WRONG %d STILL %d SAME %d ABSENT %d SHAPE-MISMATCH %d'
              % (arm, label, t['TO'], t['AWAY'], t['MOVED-WRONG'], t['STILL'],
                 t['SAME'], absent,
                 len([x for x in lines if 'SHAPE-MISMATCH' in x])))


if __name__ == '__main__':
    main()
