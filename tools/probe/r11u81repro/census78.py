#!/usr/bin/env python3
"""r11u78 A-PRIORI MOVER CENSUS — which corpus tests can reach THIS pass's
five faces.

Every law here re-spells or re-sizes a cell of the ELABORATED pattern-operand
fold, so the population is r11u66's setter population, taken through the very
`census68_base` r11u73 and r11u76 import rather than a copy — WIDENED by one
class: LAW C writes on the reduce table's `vpiUIntConst` face, which
`classify` calls UINTISH, so INTISH + CAST + UINTISH is the population here.
The subclasses are this pass's divergence classes:

  UNSARM78  LAW C. A setter that is an ARM and reaches a SIZED
            BASED literal (through parameter NAME hops).  That is a strict
            SUPERSET of the write's gate, which additionally requires the
            reduce table to encode the arm `vpiUIntConst` and the producer's
            64-bit answer to differ from the member-masked one — neither of
            which is decidable from the sources (the member width is not in
            the setter).
  SHIFT78   LAW D. The name-expanded setter contains `>>`, `>>>`, `<<` or
            `<<<`.  Superset: the shift arms also newly reach the BAIL when a
            leaf refuses, which moves sizes even where LAW C declines.
  PAREN78   R1. A PARENTHESISED sized based literal inside such a setter —
            the encoding classifier's blind spot that
            § caSubstLeafCtSeesParens78 closes.
  TSCAST78  LAW A. A signedness cast on the producer's `return c` face whose
            argument IS the literal, with no NAME between them (the typespec
            write declines a hop).  Subset of SCAST.
  SCAST     LAW B (and r11u76's, unchanged). A signedness cast on that face,
            argument reached through NAME hops included.
  AGREE     a setter in that population none of the above can reach

SUPERSET BY CONSTRUCTION: sources only, no check that the pattern's parameter
is struct-typed, that the flat fold happens, that the values actually diverge
at the emitted operand, or that the setter survives the admission fences.  The
measured movers must be a SUBSET of the non-AGREE names.

usage:  census78.py [<corpus dir> ...]      (default: both pinned corpora)
        census78.py --selftest              (the positive control on the grid)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
for cand in (os.path.join(HERE, '..', 'r11u72repro'),
             os.path.expanduser(
                 '~/git-repos/slang-uhdm/tools/probe/r11u72repro')):
    if os.path.isdir(cand):
        sys.path.insert(0, cand)
        break
import census68_base as C                                      # noqa: E402

for cand in (os.path.join(HERE, '..', 'r11u76repro'),
             os.path.expanduser(
                 '~/git-repos/slang-uhdm/tools/probe/r11u76repro')):
    if os.path.isdir(cand):
        sys.path.insert(0, cand)
        break
import census76 as C76                                         # noqa: E402

LIT = C76.LIT
SCASTRE = C76.SCASTRE
SHIFTRE = re.compile(r'<<<|>>>|<<|>>')
PARENLIT = re.compile(r"\(\s*\d+'[sS]?[hHbBoOdD][0-9a-fA-F_]+\s*\)")
ARMRE = re.compile(r'[-+*/%]|\*\*|<<|>>|&|\|')


def arm_with_based_leaf(s, inits):
    """an ARM (a binary operator at any depth) that reaches a sized based
    literal, following parameter NAME initializers as the reduce does"""
    x = C76.name_expand(s, inits)
    return bool(ARMRE.search(s)) and bool(LIT.search(x))


def scast_direct(x, inits, depth=0):
    """a signedness cast on a `return c` face whose ARGUMENT is the literal
    itself — no NAME between the cast and the literal (LAW A declines a hop)"""
    if depth > 6:
        return False
    for m in SCASTRE.finditer(x):
        sgn = (m.group(1) or m.group(2)).lower() == 'signed'
        i = x.find('(', m.start())
        if i < 0:
            continue
        d, j = 0, i
        while j < len(x):
            if x[j] == '(':
                d += 1
            elif x[j] == ')':
                d -= 1
                if d == 0:
                    break
            j += 1
        a = x[i + 1:j].strip()
        lm = LIT.fullmatch(a.replace(' ', ''))
        if not lm:
            continue                      # a NAME argument: declined by LAW A
        if sgn and lm.group(3).lower() != 'd':
            continue                      # $signed on h/b/o MINTS
        return True
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm in inits and scast_direct(inits[nm], inits, depth + 1):
            return True
    return False


def subclass(s, inits):
    out = set()
    x = C76.name_expand(s, inits)
    if arm_with_based_leaf(s, inits):
        out.add('UNSARM78')
    if SHIFTRE.search(x):
        out.add('SHIFT78')
    if PARENLIT.search(x):
        out.add('PAREN78')
    if C76.scast_passthru(s, inits):
        out.add('SCAST')
    if scast_direct(s, inits):
        out.add('TSCAST78')
    return sorted(out) or ['AGREE']


def scan(roots, loose=False):
    hits, hist = {}, {}
    for root in roots:
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn
                     if d not in ('.git', 'slpp_all', 'slpp_unit')]
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
                for pre, body in C.spans(t):
                    if not loose and not re.search(
                            r'\b(parameter|localparam)\b', pre):
                        continue
                    for el in C.split_top(body):
                        s = C.setter_of(el)
                        c = C.classify(s, inits)
                        hist[c] = hist.get(c, 0) + 1
                        # THE POPULATION IS WIDER THAN r11u76'S.  Pass 76's
                        # two laws only ever touched the `vpiIntConst` face
                        # and the cast, so its census took INTISH + CAST.
                        # LAW C writes on the `vpiUIntConst` face, which
                        # `census68_base.classify` calls UINTISH (the shifts,
                        # the bitwise arms, an unsigned `+`), so UINTISH is
                        # part of this pass's population and is added here.
                        if c not in ('INTISH', 'CAST', 'UINTISH'):
                            continue
                        for k in subclass(s, inits):
                            hist['@' + k] = hist.get('@' + k, 0) + 1
                            if k != 'AGREE':
                                hits.setdefault(
                                    C.testname(root, p), set()).add(
                                        '%s: %s' % (k, s[:56]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must SIGHT each law's own grid arm."""
    want = {'z3_uns78': 'UNSARM78', 'z4_shift78': 'SHIFT78',
            'y2_digits76': 'UNSARM78', 'y5_paren76': 'PAREN78',
            'z1_ts78': 'TSCAST78', 'z2_hop78': 'SCAST'}
    dirs = [os.path.join(HERE, 'grid'),
            os.path.join(HERE, '..', 'r11u76repro', 'grid'),
            os.path.join(HERE, '..', 'r11v76repro', 'grid'),
            os.path.join(HERE, '..', 'r11v73repro', 'grid')]
    seen = {}
    files = []
    for d in dirs:
        if os.path.isdir(d):
            files += [(f, os.path.join(d, f)) for f in sorted(os.listdir(d))]
    for f, fp in sorted(files):
        if not f.endswith('.sv'):
            continue
        t = C.strip_noise(open(fp, errors='replace').read())
        inits = C.param_inits(t)
        ks = set()
        for pre, body in C.spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                s = C.setter_of(el)
                if C.classify(s, inits) in ('INTISH', 'CAST', 'UINTISH'):
                    ks |= set(subclass(s, inits))
        seen.setdefault(f[:-3], set())
        seen[f[:-3]] |= ks
    ok = True
    for a, k in sorted(want.items()):
        print('  %-16s %s' % (a, ' '.join(sorted(seen.get(a, set()))) or '-'))
        if k not in seen.get(a, set()):
            print('  ARM %s does NOT carry class %s — the scanner is blind'
                  % (a, k))
            ok = False
    print('SELFTEST %s' % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 4


if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if '--selftest' in sys.argv:
        sys.exit(selftest())
    roots = args or C.DEFAULT
    for loose in (False, True):
        hits, hist = scan(roots, loose)
        print('== %s' % ('LOOSE (every pattern span)' if loose
                         else 'STRICT (parameter/localparam spans only)'))
        print('   ' + ' '.join('%s=%d' % (k, hist[k])
                               for k in sorted(hist) if not k.startswith('@')))
        print('   ' + ' '.join('%s=%d' % (k[1:], hist[k])
                               for k in sorted(hist) if k.startswith('@')))
        print('   CANDIDATES %d' % len(hits))
        for t in sorted(hits):
            for h in sorted(hits[t]):
                print('     %-44s %s' % (t, h))
