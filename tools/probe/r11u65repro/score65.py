#!/usr/bin/env python3
"""r11u65 GRID SCORER — per arm, classify every (view, path, net, kind) key by
the golden / pristine / law triple of VpiNetType multisets:
  TO-GOLDEN   pristine disagreed, law agrees
  AWAY-GOLDEN pristine agreed,    law disagrees   (must be 0)
  STILL-WRONG both disagree
  SAME        both agree
plus ONLY-GOLDEN / ONLY-OURS key-set differences, base and law.
Calibration golden-vs-golden runs first on every arm."""
import os, subprocess, sys, collections
HERE = os.path.dirname(os.path.abspath(__file__))
GRID = os.environ.get('GRID', os.path.join(HERE, 'grid'))
CEN = os.path.join(HERE, 'netcen65')

def rows(db):
    out = {}
    if not os.path.isfile(db):
        return None
    r = subprocess.run([CEN, '--list', db], capture_output=True, text=True)
    for line in r.stdout.splitlines():
        if not line.startswith(('DEF|', 'ELAB|')):
            continue
        f = line.split('|')
        key = (f[0], f[1], f[2], f[3])
        out.setdefault(key, []).append(int(f[7].split('=')[1]))
    for v in out.values():
        v.sort()
    return out

tot = collections.Counter()
for arm in sorted(os.listdir(GRID)):
    g = os.path.join(GRID, arm, 'slpp_all', 'surelog.uhdm')
    b = os.path.join(GRID, arm, 'ours.base.uhdm')
    l = os.path.join(GRID, arm, 'ours.law.uhdm')
    G, B, L = rows(g), rows(b), rows(l)
    if G is None or B is None or L is None:
        print('SKIP %-18s (missing database)' % arm); continue
    calib = 'CALIB-OK' if rows(g) == G else 'CALIB-FAIL'
    c = collections.Counter()
    for k in sorted(set(G) | set(B) | set(L)):
        gv, bv, lv = G.get(k), B.get(k), L.get(k)
        if gv is None:
            c['ONLY-OURS'] += 1; continue
        if bv is None and lv is None:
            c['ONLY-GOLDEN'] += 1; continue
        if bv is None or lv is None:
            c['KEYSET-MOVED'] += 1
            print('  KEYSET %s %s base=%s law=%s golden=%s' % (arm, k, bv, lv, gv))
            continue
        if bv == gv and lv == gv: c['SAME'] += 1
        elif bv != gv and lv == gv:
            c['TO-GOLDEN'] += 1
            print('  TO-GOLDEN   %s %s golden=%s base=%s law=%s' % (arm, k, gv, bv, lv))
        elif bv == gv and lv != gv:
            c['AWAY-GOLDEN'] += 1
            print('  AWAY-GOLDEN %s %s golden=%s base=%s law=%s' % (arm, k, gv, bv, lv))
        else:
            c['STILL-WRONG'] += 1
            if bv != lv:
                print('  MOVED-WRONG %s %s golden=%s base=%s law=%s' % (arm, k, gv, bv, lv))
                c['MOVED-WRONG'] += 1
    tot.update(c)
    print('ARM %-18s %s %s' % (arm, calib, ' '.join('%s=%d' % (k, c[k]) for k in
          ('SAME','TO-GOLDEN','AWAY-GOLDEN','STILL-WRONG','MOVED-WRONG','ONLY-GOLDEN','ONLY-OURS','KEYSET-MOVED'))))
print('TOTAL ' + ' '.join('%s=%d' % (k, tot[k]) for k in
      ('SAME','TO-GOLDEN','AWAY-GOLDEN','STILL-WRONG','MOVED-WRONG','ONLY-GOLDEN','ONLY-OURS','KEYSET-MOVED')))
