#!/usr/bin/env python3
"""r11u78 GRID SCORER — one cell per pattern OPERAND, scored on the four
fields `expr::Compare` / `constant::Compare` read plus the value byte:
`vpiSize`, `vpiConstType`, `VpiValue` and the `vpiTypespec` chain, exactly as
`ts78.py` prints them.

For each arm it reads `<arm>.g.dump`, `<arm>.<pris tag>.dump` and
`<arm>.<law tag>.dump`, joins the operand lists POSITIONALLY per param_assign
(the listing + Lhs name + location is the key), and classifies every operand:

  TO      pristine != golden, law == golden          (a conversion)
  AWAY    pristine == golden, law != golden          (a regression)
  STILL   both differ from golden, law == pristine    (untouched)
  WRONG2  both differ from golden, law != pristine    (moved, still wrong)
  EQ      all three agree

A SHAPE mismatch (a different number of operands, or an operand that is not a
constant) is reported as SHAPE and counted separately — never silently joined.

usage: score78.py <grid dir> <pris tag> <law tag> [<arm> ...]"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ts78                                                    # noqa: E402


def cells(path):
    out = {}
    for sect, name, loc, d in ts78.parse(path):
        key = (sect, name, loc)
        if not d.startswith('op='):
            out.setdefault(key, []).append(d)
            continue
        ops = d.split('ops=[', 1)[1].rstrip(']')
        out[key] = ops.split(' ') if ops else []
    return out


def main(gdir, ptag, ltag, arms):
    tot = {'TO': 0, 'AWAY': 0, 'STILL': 0, 'WRONG2': 0, 'EQ': 0, 'SHAPE': 0}
    for a in arms:
        g = os.path.join(gdir, a + '.g.dump')
        p = os.path.join(gdir, '%s.%s.dump' % (a, ptag))
        l = os.path.join(gdir, '%s.%s.dump' % (a, ltag))
        if not (os.path.exists(g) and os.path.exists(p) and os.path.exists(l)):
            print('  %-16s MISSING DUMP' % a)
            continue
        G, P, L = cells(g), cells(p), cells(l)
        sub = {k: 0 for k in tot}
        lines = []
        for key in sorted(set(G) | set(P) | set(L)):
            gv, pv, lv = G.get(key), P.get(key), L.get(key)
            if gv is None or pv is None or lv is None or \
                    not (len(gv) == len(pv) == len(lv)):
                sub['SHAPE'] += 1
                lines.append('    SHAPE  %s g=%s p=%s l=%s'
                             % (key[1],
                                len(gv) if gv is not None else '-',
                                len(pv) if pv is not None else '-',
                                len(lv) if lv is not None else '-'))
                continue
            for i, (gc, pc, lc) in enumerate(zip(gv, pv, lv)):
                if gc == pc == lc:
                    sub['EQ'] += 1
                    continue
                if pc != gc and lc == gc:
                    k = 'TO'
                elif pc == gc and lc != gc:
                    k = 'AWAY'
                elif lc == pc:
                    k = 'STILL'
                else:
                    k = 'WRONG2'
                sub[k] += 1
                if k != 'STILL':
                    lines.append('    %-6s %s op%-2d  g=%s  p=%s  l=%s'
                                 % (k, key[1], i, gc, pc, lc))
        print('  %-16s TO=%d AWAY=%d STILL=%d WRONG2=%d EQ=%d SHAPE=%d'
              % (a, sub['TO'], sub['AWAY'], sub['STILL'], sub['WRONG2'],
                 sub['EQ'], sub['SHAPE']))
        for ln in lines:
            print(ln)
        for k in tot:
            tot[k] += sub[k]
    print('TOTAL TO=%d AWAY=%d STILL=%d WRONG2=%d EQ=%d SHAPE=%d'
          % (tot['TO'], tot['AWAY'], tot['STILL'], tot['WRONG2'], tot['EQ'],
             tot['SHAPE']))
    return 0


if __name__ == '__main__':
    d, pt, lt = sys.argv[1], sys.argv[2], sys.argv[3]
    ar = sys.argv[4:]
    if not ar:
        ar = sorted(f[:-3] for f in os.listdir(d) if f.endswith('.sv'))
    sys.exit(main(d, pt, lt, ar))
