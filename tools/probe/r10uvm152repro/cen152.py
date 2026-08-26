#!/usr/bin/env python3
"""r10uvm152 — the CELL CENSUS.  MEASUREMENT ONLY; uhdm-cmp is the judge.

Reads three uhdm-dumps of the SAME design — GOLDEN, PRISTINE, PATCHED — and
scores every REFERENCE BINDING as a MULTISET join keyed on
(reference VpiFullName, reference line, reference column); the payload is the
multiset of `vpiActual` target VpiFullNames (`<bare>` when the reference has
none).  LHS is ALWAYS golden.

  usage: cen152.py <golden.dump> <pristine.dump> <patched.dump> [name-regex]

Reported per key, never aggregated away:
  RIGHT->RIGHT   pristine == golden and patched == golden
  WRONG->RIGHT   pristine != golden and patched == golden      (the law's work)
  RIGHT->WRONG   pristine == golden and patched != golden      (MOVED-WRONG)
  WRONG->WRONG   both differ, and whether the patched payload CHANGED
                 (a changed-but-still-wrong cell is reported separately so a
                  move AWAY from golden can never hide inside "still wrong")
  ONLY-GOLDEN / ONLY-OURS  one-sided keys, counted on BOTH runs so that an
                 unchanged one-sided count is a MEASURED fact, not an omission.

Calibration: pass the golden dump three times — every cell must read
RIGHT->RIGHT and both one-sided counts must be 0.
"""
import sys, re, collections, subprocess, os

HERE = os.path.dirname(os.path.abspath(__file__))

def scan(path, filt):
    out = subprocess.run([sys.executable, os.path.join(HERE, 'scan152.py'), path],
                         capture_output=True, text=True).stdout
    d = collections.defaultdict(collections.Counter)
    for l in out.split('\n'):
        if not l.strip():
            continue
        f = l.split('\t')
        if filt and not re.search(filt, f[0]):
            continue
        d[(f[0], f[1], f[2])][f[4] or '<bare>'] += 1
    return d

def main():
    gp, pp, qp = sys.argv[1], sys.argv[2], sys.argv[3]
    filt = sys.argv[4] if len(sys.argv) > 4 else ''
    g, p, q = scan(gp, filt), scan(pp, filt), scan(qp, filt)
    keys = sorted(set(g) | set(p) | set(q),
                  key=lambda x: (int(x[1] or 0), int(x[2] or 0), x[0]))
    c = collections.Counter()
    for k in keys:
        gv, pv, qv = g.get(k), p.get(k), q.get(k)
        if gv is None or (pv is None and qv is None):
            if gv is None:
                c['ONLY-OURS-pris'] += (pv is not None)
                c['ONLY-OURS-patc'] += (qv is not None)
            else:
                c['ONLY-GOLDEN-pris'] += 1
                c['ONLY-GOLDEN-patc'] += 1
            continue
        pr, qr = (pv == gv), (qv == gv)
        if pr and qr:
            c['RIGHT->RIGHT'] += 1
        elif not pr and qr:
            c['WRONG->RIGHT'] += 1
            print('WRONG->RIGHT', k, 'G=', dict(gv), 'P=', dict(pv or {}))
        elif pr and not qr:
            c['RIGHT->WRONG'] += 1
            print('RIGHT->WRONG', k, 'G=', dict(gv), 'Q=', dict(qv or {}))
        else:
            if pv == qv:
                c['WRONG->WRONG(unmoved)'] += 1
            else:
                c['WRONG->WRONG(MOVED)'] += 1
                print('WRONG->WRONG(MOVED)', k, 'G=', dict(gv),
                      'P=', dict(pv or {}), 'Q=', dict(qv or {}))
    for kk in ('RIGHT->RIGHT', 'WRONG->RIGHT', 'RIGHT->WRONG',
               'WRONG->WRONG(unmoved)', 'WRONG->WRONG(MOVED)',
               'ONLY-GOLDEN-pris', 'ONLY-GOLDEN-patc',
               'ONLY-OURS-pris', 'ONLY-OURS-patc'):
        print(f'{kk:24s} {c[kk]}')

main()
