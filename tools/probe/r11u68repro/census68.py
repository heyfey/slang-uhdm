#!/usr/bin/env python3
"""r11u68 A-PRIORI MOVER CENSUS — which corpus tests can reach either law.

It is a SUPERSET BY CONSTRUCTION: it reads SOURCES only and never asks whether
the pattern's parameter is struct-typed, whether the elaborated copy flat-folds
at all, whether the member widths differ from the literal's, or whether the
setter survives the admission fences.  So the measured movers must be a SUBSET
of what it prints.

LAW A (`patBailStopsMemberStamp68`) needs a `'{...}` parameter pattern with a
REFUSING setter that is NOT the last element — only operands AFTER the refusal
can move.  The refusal classes it scans for, each one measured in this pass's
`b1`/`b2`/`b3` detector arms:

  NEG    a setter whose reduce answers `vpiIntConst` with a NEGATIVE value
         (census66's INTISH classification plus a syntactic sign test)
  UNFOLD a top-level `^`, `~^`, `^~`, `===`, `!==`, `==?` or unary `+`
  XLEAD  a based literal whose LEADING digit is unknown (`1'bx`, `8'hX`)

LAW B (`caSubstMemberStampAllEnc68`) needs a `'{...}` parameter pattern with a
BASED-LITERAL setter, which is the only class whose `vpiConstType` reaches the
cont_assign substitution's member stamp with a size of its own.

usage:  census68.py [<corpus dir> ...]      (default: both pinned corpora)
        census68.py --selftest              (the positive control on the grid)
"""
import os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import census68_base as C

UNFOLD = ('^', '~^', '^~', '===', '!==', '==?')
XLEAD = re.compile(r"^\d*'[sS]?[hHbBoOdD][xXzZ?]", re.I)


def refusal(x, inits):
    """the refusal class of one setter text, or '' when the walk completes"""
    x = x.strip()
    while x.startswith('(') and x.endswith(')'):
        x = x[1:-1].strip()
    if not x:
        return ''
    if XLEAD.match(x):
        return 'XLEAD'
    y = re.sub(r"\d*'[sS]?[hHbBoOdDxXzZ][0-9a-fA-FxXzZ?_]+", ' NUM ', x)
    # a top-level unary `+` — `reduceExpr` has no vpiPlusOp arm and the op
    # survives (arm b3 `uplus`, golden op2)
    if y.lstrip().startswith('+'):
        return 'UNFOLD'
    for tok in ('===', '!==', '==?', '~^', '^~', '^'):
        d = 0
        i = 0
        while i < len(y):
            ch = y[i]
            if ch in '({[':
                d += 1
            elif ch in ')}]':
                d -= 1
            elif d == 0 and y.startswith(tok, i):
                # `^` must not match inside `~^`/`^~`/`^=`
                if tok == '^' and (y[i - 1:i] in ('~',) or y[i + 1:i + 2] in ('~', '=')):
                    i += 1
                    continue
                return 'UNFOLD'
            i += 1
    if C.classify(x, inits) == 'INTISH':
        # the NEGATIVE half: a leading unary minus, or a subtract whose left
        # operand is a bare literal smaller than its right (the only shapes a
        # source scan can call; every other INTISH setter rides as a CANDIDATE)
        if x.lstrip().startswith('-'):
            return 'NEG'
        return 'NEG?'
    return ''


def scan(roots, loose=False):
    lawa, lawb = {}, {}
    hist = {}
    for root in roots:
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn if d not in ('.git', 'slpp_all', 'slpp_unit')]
            for f in fn:
                if not f.endswith(C.EXTS):
                    continue
                p = os.path.join(dp, f)
                try:
                    t = C.strip_noise(open(p, errors='replace').read())
                except OSError:
                    continue
                if "'{" not in t:
                    continue
                inits = C.param_inits(t)
                name = C.testname(root, p)
                for pre, body in C.spans(t):
                    if not loose and not re.search(
                            r'\b(parameter|localparam)\b', pre):
                        continue
                    els = [C.setter_of(e) for e in C.split_top(body)]
                    for i, s in enumerate(els):
                        r = refusal(s, inits)
                        hist[r or 'OK'] = hist.get(r or 'OK', 0) + 1
                        if r and i < len(els) - 1:
                            lawa.setdefault(name, set()).add(
                                '%s:%s' % (r, s[:48]))
                        if C.BASED.match(s):
                            lawb.setdefault(name, set()).add(s[:48])
    return lawa, lawb, hist


def selftest():
    here = os.path.dirname(os.path.abspath(__file__))
    cases = [("KU ^ 3", 'UNFOLD'), ("KU ~^ 3", 'UNFOLD'), ("KU ^~ 3", 'UNFOLD'),
             ("K === 6", 'UNFOLD'), ("K !== 6", 'UNFOLD'), ("K ==? 6", 'UNFOLD'),
             ("+K", 'UNFOLD'), ("1'bx", 'XLEAD'), ("8'hX", 'XLEAD'),
             ("8'bx0000001", 'XLEAD'), ("-K", 'NEG'), ("-16'd5", 'NEG'),
             ("2 - 5", 'NEG?'), ("K * 2", 'NEG?'),
             # the classes that must NOT read as a refusal
             ("3", ''), ("K", ''), ("8'hA5", ''), ("8'b1x01", ''),
             ("8'b1000000x", ''), ("KU & 3", ''), ("KU | 8", ''),
             ("KU << 1", ''), ("K > 2", ''), ("K ? 3 : 4", ''),
             ("$clog2(40)", ''), ("{4'd1, 4'd2}", ''), ("~KU", ''),
             ("K == 6", ''), ("K != 6", '')]
    inits = {'K': '6', 'KU': '6'}
    bad = 0
    for txt, want in cases:
        got = refusal(txt, inits)
        ok = got == want
        bad += 0 if ok else 1
        print('  %s %-16s -> %-7s (want %s)' % ('ok ' if ok else 'BAD', txt,
                                                got or '-', want or '-'))
    # THE POSITIVE CONTROL: the grid arms this pass measured must be FOUND.
    # GRID= points at a directory holding the arms; the default is this pass's
    # own `grid/`, and the BORROWED arms (r11u66's / r11v66's) are required only
    # when the operator has copied them in, as §8 of the README says to.
    grid = os.environ.get('GRID', os.path.join(here, 'grid'))
    lawa, lawb, _ = scan([grid if os.path.isdir(grid) else here])
    def req(kind, table, own, borrowed):
        n = 0
        for a in sorted(own) + sorted(borrowed):
            present = os.path.exists(os.path.join(grid, a + '.sv'))
            if a in borrowed and not present:
                print('  --  %s arm %s NOT PRESENT (copy it in per README §8)'
                      % (kind, a))
                continue
            hit = any(k.startswith(a) or k == a + '.sv' for k in table)
            print('  %s %s arm %s' % ('ok ' if hit else 'BLIND', kind, a))
            n += 0 if hit else 1
        return n
    bad += req('LAW-A', lawa,
               {'b1_refuse68', 'b2_faces68', 'b3_ops68', 'b4_postsz68',
                'b5_redsz68'},
               {'x1_optable', 'v9', 'g3_neg66', 'a1_ovf66'})
    bad += req('LAW-B', lawb, {'b1_refuse68', 'b5_redsz68'}, {'g4_base66'})
    print('SELFTEST %s (%d bad)' % ('PASS' if bad == 0 else 'FAIL', bad))
    return bad


def main():
    if '--selftest' in sys.argv:
        sys.exit(1 if selftest() else 0)
    roots = [a for a in sys.argv[1:] if not a.startswith('-')] or C.DEFAULT
    lawa, lawb, hist = scan(roots)
    print('SETTER HISTOGRAM: %s' % ' '.join(
        '%s=%d' % kv for kv in sorted(hist.items())))
    print('LAW-A CANDIDATE TESTS (%d):' % len(lawa))
    for k in sorted(lawa):
        print('  %-44s %s' % (k, ' | '.join(sorted(lawa[k]))[:120]))
    print('LAW-B CANDIDATE TESTS (%d):' % len(lawb))
    for k in sorted(lawb):
        print('  %-44s %s' % (k, ' | '.join(sorted(lawb[k]))[:120]))


if __name__ == '__main__':
    main()
