#!/usr/bin/env python3
"""r11u68 THREE-WAY cont_assign CELL SCORER — golden vs PRISTINE vs LAW at the
elaborated cont_assign Rhs, in three projections (SIZE = the half LAW B owns,
VAL = vpiDecompile + vpiConstType, FULL = both).  Cells are keyed by the Lhs
ref_obj's instance-qualified name; a dump that yields ZERO cont_assign records
exits 4 through caread55.py, so a reader that reaches nothing cannot read as
agreement.
usage: ca68.py <gold.dump> <pris.dump> <law.dump> <arm>"""
import os, re, subprocess, sys
CAREAD = os.environ.get("CAREAD", os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "caread55.py"))


def cells(dump):
    out = subprocess.run([sys.executable, CAREAD, dump, "ELAB"],
                         capture_output=True, text=True)
    if out.returncode != 0:
        sys.stderr.write("READER FAILED on %s\n" % dump)
        sys.exit(4)
    d = {}
    for l in out.stdout.splitlines():
        m = re.search(r'LHS=ref_obj\(\(([^)]+)\)\)', l)
        if not m:
            continue
        v = re.search(r'RHS=(\S+)\s+@(\S+)\s+(.*)$', l)
        d[m.group(1)] = (v.group(3).strip() if v else l)
    return d


def proj_size(c):
    m = re.search(r'vpiSize:(-?\d+)', c)
    return m.group(1) if m else c


def proj_val(c):
    return re.sub(r'vpiSize:-?\d+\s*', '', c)


def main():
    gp, pp, lp, arm = sys.argv[1:5]
    g, p, l = cells(gp), cells(pp), cells(lp)
    if not g:
        sys.stderr.write("NO ELAB cont_assign IN GOLDEN — scorer blind\n")
        sys.exit(4)
    for label, proj in (("SIZE", proj_size), ("VAL", proj_val),
                        ("FULL", lambda c: c)):
        t = {'TO': 0, 'AWAY': 0, 'MOVED-WRONG': 0, 'STILL': 0, 'SAME': 0}
        for k in sorted(set(g) | set(p) | set(l)):
            gv = proj(g.get(k, '<none>'))
            pv = proj(p.get(k, '<none>'))
            lv = proj(l.get(k, '<none>'))
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
            if v in ('TO', 'AWAY', 'MOVED-WRONG'):
                print('  %-11s %-34s\n     G %s\n     P %s\n     L %s'
                      % (v, k, gv, pv, lv))
        print('ARM %s %s TO %d AWAY %d MOVED-WRONG %d STILL %d SAME %d'
              % (arm, label, t['TO'], t['AWAY'], t['MOVED-WRONG'], t['STILL'],
                 t['SAME']))


if __name__ == '__main__':
    main()
