#!/usr/bin/env python3
"""r10uvm163 — cells163.py: the three-way arm table.  For one arm workdir it
prints, per NAMED cell, golden's listing, the PRISTINE binary's and the PATCHED
binary's, and scores each cell.

LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.  MEASUREMENT ONLY.

    usage: cells163.py <armdir> <g.cen-suffix pairs...>   (see below)
           cells163.py <armdir> [<name-regex>]
           cells163.py --selftest

It reads `<armdir>/{g,o,q}.cen` (DEF view) and `<armdir>/{ge,oe,qe}.cen` (ELAB
view) — the ct163cen listings the driver writes — and reports per view:

    TO-GOLDEN   pristine disagreed with golden and patched agrees   (a WIN)
    HELD        both agreed with golden and still do                (a FENCE)
    MOVED-WRONG pristine agreed and patched does not                (a LOSS)
    AWAY        patched disagrees in a way pristine did not, where
                golden has NO listing and we now have one           (a LOSS)
    STILL       both disagreed and still disagree
    ONLY-G/ONLY-O  the cell exists on one side only

GUARDS:
  * a view whose three listings are not all present is reported MISSING and
    counted — a scorer that reads nothing must never print a clean table;
  * a NULL and an EMPTY Parameters vector are the same cell to UHDM's vector
    SafeCompare, and are folded together here exactly as score163.py does;
  * --selftest is the positive control over a built-in fixture.
"""
import os
import re
import sys

CELL = re.compile(r'^CELL (\S+) \| nparam=(-?\d+) \| params=(.*?) \| npa=')


def load(path):
    d = {}
    if not os.path.exists(path):
        return None
    for ln in open(path):
        m = CELL.match(ln)
        if m:
            d.setdefault(m.group(1), []).append((max(int(m.group(2)), 0), m.group(3)))
    for v in d.values():
        v.sort()
    return d


def score_view(g, o, q, pat, rows):
    hist = {}
    for k in sorted(set(g) | set(o) | set(q)):
        if pat and not pat.search(k):
            continue
        gl, ol, ql = g.get(k, []), o.get(k, []), q.get(k, [])
        n = max(len(gl), len(ol), len(ql))
        for i in range(n):
            gv = gl[i] if i < len(gl) else None
            ov = ol[i] if i < len(ol) else None
            qv = ql[i] if i < len(ql) else None
            if gv is None:
                c = 'ONLY-O'
            elif ov is None and qv is None:
                c = 'ONLY-G'
            elif qv is None:
                c = 'STILL'
            else:
                pre_ok = ov is not None and ov == gv
                post_ok = qv == gv
                if pre_ok and post_ok:
                    c = 'HELD'
                elif not pre_ok and post_ok:
                    c = 'TO-GOLDEN'
                elif gv[0] == 0 and qv[0] > 0 and (ov is None or ov[0] == 0):
                    # AWAY is the SEVERE face of MOVED-WRONG and is tested
                    # FIRST: a listing MINTED where golden has none.  Scoring it
                    # after the generic MOVED-WRONG test would have hidden every
                    # over-firing cell inside the milder label.
                    c = 'AWAY'
                elif pre_ok and not post_ok:
                    c = 'MOVED-WRONG'
                else:
                    c = 'STILL'
            hist[c] = hist.get(c, 0) + 1
            rows.append((c, k, gv, ov, qv))
    return hist


def run(armdir, pat):
    pat = re.compile(pat) if pat else None
    rc = 0
    for view, sfx in (('DEF', ('g', 'o', 'q')), ('ELAB', ('ge', 'oe', 'qe'))):
        ls = [load(os.path.join(armdir, s + '.cen')) for s in sfx]
        if any(x is None for x in ls):
            print(f'{view}: MISSING listing ({sfx})')
            rc = 1
            continue
        rows = []
        hist = score_view(*ls, pat, rows)
        print(f'-- {view} ' + ' '.join(f'{k}={hist.get(k,0)}' for k in
                                       ('HELD', 'TO-GOLDEN', 'MOVED-WRONG', 'AWAY',
                                        'STILL', 'ONLY-G', 'ONLY-O')))
        for c, k, gv, ov, qv in rows:
            if c in ('HELD',):
                continue
            print(f'   {c:12s} {k}')
            print(f'                G={gv}  pris={ov}  patc={qv}')
    return rc


def selftest():
    import tempfile
    d = tempfile.mkdtemp(prefix='cells163_')
    def w(n, lines):
        open(os.path.join(d, n + '.cen'), 'w').write('\n'.join(lines) + '\n')
    base = ' | npa=1 | holder=class_var | cdefn=p::g | cdp=1 | home=<x'
    w('g', ['CELL win@1:1|a@1:9 | nparam=1 | params=T:int_typespec:' + base,
            'CELL fen@2:1|b@2:9 | nparam=-1 | params=' + base,
            'CELL away@3:1|c@3:9 | nparam=-1 | params=' + base,
            'CELL loss@4:1|d@4:9 | nparam=1 | params=T:int_typespec:' + base])
    w('o', ['CELL win@1:1|a@1:9 | nparam=-1 | params=' + base,
            'CELL fen@2:1|b@2:9 | nparam=-1 | params=' + base,
            'CELL away@3:1|c@3:9 | nparam=-1 | params=' + base,
            'CELL loss@4:1|d@4:9 | nparam=1 | params=T:int_typespec:' + base])
    w('q', ['CELL win@1:1|a@1:9 | nparam=1 | params=T:int_typespec:' + base,
            'CELL fen@2:1|b@2:9 | nparam=-1 | params=' + base,
            'CELL away@3:1|c@3:9 | nparam=1 | params=T:int_typespec:' + base,
            'CELL loss@4:1|d@4:9 | nparam=2 | params=T:int_typespec:,U:int_typespec:' + base])
    for s in ('ge', 'oe', 'qe'):
        w(s, ['CELL fen@2:1|b@2:9 | nparam=-1 | params=' + base])
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        run(d, None)
    out = buf.getvalue()
    want_def = '-- DEF HELD=1 TO-GOLDEN=1 MOVED-WRONG=1 AWAY=1 STILL=0 ONLY-G=0 ONLY-O=0'
    want_elab = '-- ELAB HELD=1 TO-GOLDEN=0 MOVED-WRONG=0 AWAY=0 STILL=0 ONLY-G=0 ONLY-O=0'
    ok = want_def in out and want_elab in out
    print(out.strip())
    print('SELFTEST ' + ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(run(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None))
