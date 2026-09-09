#!/usr/bin/env python3
"""r10v226 — THREE-WAY score: golden vs pristine vs patched, per process CELL.

  TO-GOLDEN   pristine disagreed with golden, patched agrees      (the move)
  AWAY        pristine agreed with golden, patched does not       (a REGRESSION)
  STILL-WRONG both disagree
  SAME-RIGHT  both agree
Cells are keyed by (section/scope, position).  A cell golden does not have at
all is an EXTRA; a golden cell nobody has is MISSING — both are scored, so an
over-mint cannot hide as an absence.
"""
import sys, os, subprocess

CEN = '/tmp/v226_proccen.py'


def cen(path):
    if not os.path.exists(path):
        return None
    out = subprocess.run([sys.executable, CEN, path], capture_output=True,
                         text=True).stdout
    d = {}
    for line in out.splitlines():
        if not line.startswith('CELL '):
            continue
        k, _, v = line[5:].partition(' | ')
        d[k.strip()] = v.strip()
    return d


def main():
    root = sys.argv[1]
    only = sys.argv[2] if len(sys.argv) > 2 else None
    tg = aw = sw = sr = 0
    for n in sorted(os.listdir(root)):
        a = os.path.join(root, n)
        if not os.path.isdir(a):
            continue
        if only and n != only:
            continue
        g = cen(os.path.join(a, 'golden.dump'))
        p = cen(os.path.join(a, 'pris.dump'))
        q = cen(os.path.join(a, 'pat.dump'))
        if g is None or p is None or q is None:
            print('ARM %-22s SKIP (missing dump)' % n)
            continue
        keys = set(g) | set(p) | set(q)
        # drop the builtin package, which no arm legislates over
        keys = {k for k in keys if 'builtin' not in k}
        atg = aaw = asw = asr = 0
        det = []
        for k in sorted(keys):
            gv, pv, qv = g.get(k, '<ABSENT>'), p.get(k, '<ABSENT>'), q.get(k, '<ABSENT>')
            if pv == gv and qv == gv:
                asr += 1
            elif pv != gv and qv == gv:
                atg += 1
                det.append('   TO-GOLDEN   %s  pris=%s -> %s' % (k, pv, qv))
            elif pv == gv and qv != gv:
                aaw += 1
                det.append('   AWAY!!      %s  golden=%s  pris=%s  pat=%s' % (k, gv, pv, qv))
            else:
                asw += 1
                det.append('   still-wrong %s  golden=%s  pat=%s' % (k, gv, qv))
        print('ARM %-22s TO-GOLDEN %-4d AWAY %-4d STILL-WRONG %-4d SAME-RIGHT %-4d' %
              (n, atg, aaw, asw, asr))
        for d in det:
            print(d)
        tg += atg; aw += aaw; sw += asw; sr += asr
    print('TOTAL  TO-GOLDEN %d  AWAY %d  STILL-WRONG %d  SAME-RIGHT %d' % (tg, aw, sw, sr))


main()
