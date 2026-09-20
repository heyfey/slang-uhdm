#!/usr/bin/env python3
"""r11u66 THREE-WAY CELL SCORER — golden vs PRISTINE vs LAW, per elaborated
pattern operand, encoding-AWARE.

Every cell is scored twice:

  FULL      the whole cell (kind + vpiSize + vpiConstType + the VALUE text)
  ENC       the ENCODING HALF only (vpiConstType + the VALUE text); the SIZE
            half is owned by the landed width laws (§ elabUnpStructOperandWidth61
            and the >64b / bail rules) and rides here as a CONTROL, so a cell
            whose size golden and we already disagree on still scores its
            encoding.

verdicts:
  TO           wrong on pristine, RIGHT on the law binary
  AWAY         RIGHT on pristine, wrong on the law binary      <- must be 0
  MOVED-WRONG  wrong on both AND the law changed it            <- must be 0
  STILL        wrong on both, the law did not touch it
  SAME         right on both

usage: cmp66.py <golden.dump> <pristine.dump> <law.dump> <armname>
exit 4 when golden yields no elaborated op75 row (a blind scorer).
"""
import sys, os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape

ELAB = ('uhdmtopModules', 'uhdmtopPackages', 'uhdmtopInterfaces',
        'uhdmallModules', 'uhdmallPackages', 'uhdmallInterfaces')


def rows(path):
    out = {}
    for sect, name, loc, d in shape.parse(path):
        if sect not in ELAB or not d.startswith('op=75 ') or name == '?':
            continue
        out[(sect, name)] = d.split('ops=[', 1)[1].rstrip(']').split()
    return out


def enc(cell):
    """the ENCODING half of a cell: everything but the vpiSize"""
    if not cell.startswith('const/'):
        return cell
    rest = cell[len('const/'):]
    return 'const@' + rest.split('@', 1)[1] if '@' in rest else cell


def size_of(cell):
    """the SIZE half of a cell, '-' for a non-constant"""
    if not cell.startswith('const/'):
        return '-'
    return cell[len('const/'):].split('@', 1)[0]


def score(g, p, l, proj, encaware=False):
    tally = {'TO': 0, 'AWAY': 0, 'ENC-TO': 0, 'MOVED-WRONG': 0, 'STILL': 0,
             'SAME': 0}
    lines = []
    for k in sorted(g):
        gc = g[k]
        pc = p.get(k)
        lc = l.get(k)
        if pc is None and lc is None:
            lines.append('  ABSENT %-16s %-28s %d cells (neither binary emits '
                         'this row)' % (k[0], k[1], len(gc)))
            continue
        pc = pc or []
        lc = lc or []
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
            elif (encaware and i < len(pc) and i < len(lc) and
                  enc(gc[i]) == enc(lc[i]) and enc(gc[i]) != enc(pc[i]) and
                  size_of(pc[i]) == size_of(lc[i])):
                # the ENCODING half converged on golden and the SIZE half is
                # byte-unchanged — the size residue belongs to the landed width
                # laws, not to this one.  This is NOT a regression.
                v = 'ENC-TO'
            else:
                v = 'MOVED-WRONG'
            tally[v] += 1
            if v != 'SAME':
                lines.append('  %-11s %-16s %-26s op%-2d golden=%-24s pris=%-24s law=%s'
                             % (v, k[0], k[1], i, gv, pv, lv))
    return tally, lines


def main():
    gp, pp, lp, arm = sys.argv[1:5]
    g, p, l = rows(gp), rows(pp), rows(lp)
    if not g:
        sys.stderr.write('NO ELABORATED op75 ROW IN GOLDEN %s — scorer blind\n' % gp)
        sys.exit(4)
    for label, proj, ea in (('FULL', lambda c: c, True), ('ENC', enc, False)):
        t, lines = score(g, p, l, proj, ea)
        print('-- %s %s' % (arm, label))
        for ln in lines:
            print(ln)
        print('ARM %s %s TO %d ENC-TO %d AWAY %d MOVED-WRONG %d STILL %d SAME %d'
              % (arm, label, t['TO'], t['ENC-TO'], t['AWAY'],
                 t['MOVED-WRONG'], t['STILL'], t['SAME']))


if __name__ == '__main__':
    main()
