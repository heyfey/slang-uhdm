#!/usr/bin/env python3
"""r11u72 A-PRIORI MOVER CENSUS — which corpus tests can reach the VALUE half.

§ patOperandIntSixtyFour72 re-spells a cell ONLY where § patOperandEnc-
ReduceTable66 / § caSubstLeafEncReduceTable56 already fire, i.e. where the
setter's reduce-table answer is `vpiIntConst` (census66's INTISH class), AND
the producer's int64 arithmetic differs from slang's self-determined-width
answer.  So this census is r11u66's INTISH population, sub-classified by which
divergence class the setter could land in:

  WRAP     a top-level `-` (binary or unary): an UNSIGNED operand pair can go
           negative in int64 where slang's own width wraps positive
           (`bit [31:0] KU = 3; KU - 5` -> golden INT:-2, ours INT:4294967294)
  OVF      a `*`, `**` or a signed `+`: the product can exceed the expression's
           self-determined width, where int64 does not wrap
           (`int BIG = 2e9; BIG * 2` -> golden INT:4000000000, ours -294967296)
  NAMEHOP  a NAME leaf whose own initializer is INTISH: the producer reduces
           the name to its STORED value, computed with the same int64 table
           (`localparam MD = -16'd5` -> golden INT:-5, ours INT:65531)
  WIDE     a BIN/HEX/OCT literal wider than 64 bits inside an int64 arm: the
           reduce REFUSES and the operation survives (§ the third refusal face)
  AGREE    an INTISH setter none of the above can reach — the two arithmetics
           coincide and the law writes the digits already there

It is a SUPERSET BY CONSTRUCTION: it reads SOURCES only and never asks whether
the pattern's parameter is struct-typed, whether the elaborated copy flat-folds
at all, whether the values actually diverge, or whether the setter survives the
admission fences.  The measured movers must be a SUBSET of the non-AGREE names.

usage:  census72.py [<corpus dir> ...]      (default: both pinned corpora)
        census72.py --selftest              (the positive control on the grid)
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import census68_base as C

WIDE = re.compile(r"^(\d+)'[sS]?[hHbBoO]", re.I)


def wide_leaf(x, inits=None, depth=0):
    """a >64-bit BIN/HEX/OCT literal reachable from the setter, through NAME
    hops — the leaf `get_value` refuses outright (the producer's own
    `VpiSize() > 64` guard), so the arm does not fold at all"""
    for m in re.finditer(r"(\d+)'[sS]?[hHbBoO][0-9a-fA-FxXzZ?_]+", x):
        if int(m.group(1)) > 64:
            return True
    if inits is None or depth > 6:
        return False
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm in inits and wide_leaf(inits[nm], inits, depth + 1):
            return True
    return False


def namehop(x, inits, depth=0):
    """a NAME leaf whose initializer is INTISH — the leaf the producer reduces
    to a STORED int64 value we would otherwise read at slang's width"""
    if depth > 6:
        return False
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm not in inits:
            continue
        if C.classify(inits[nm], inits) == 'INTISH':
            return True
        if namehop(inits[nm], inits, depth + 1):
            return True
    return False


def subclass(x, inits):
    out = []
    ops = C.toplevel_ops(x)
    if wide_leaf(x, inits):
        out.append('WIDE')
    if '-' in ops:
        out.append('WRAP')
    if any(o in ops for o in ('*', '**', '+')):
        out.append('OVF')
    if namehop(x, inits):
        out.append('NAMEHOP')
    return out or ['AGREE']


def scan(roots, loose=False):
    hits = {}
    hist = {}
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
                        if c != 'INTISH':
                            continue
                        for k in subclass(s, inits):
                            hist['@' + k] = hist.get('@' + k, 0) + 1
                            if k != 'AGREE':
                                hits.setdefault(
                                    C.testname(root, p), set()).add(
                                        '%s: %s' % (k, s[:56]))
    return hits, hist


def selftest():
    here = os.path.dirname(os.path.abspath(__file__))
    grid = os.path.join(here, 'grid')
    want = {'t1_arith72': 'OVF', 't2_leaf72': 'NAMEHOP',
            't3_beyond72': 'WIDE', 't5_untyped72': 'NAMEHOP'}
    seen = {}
    for f in sorted(os.listdir(grid)):
        if not f.endswith('.sv'):
            continue
        t = C.strip_noise(open(os.path.join(grid, f), errors='replace').read())
        inits = C.param_inits(t)
        ks = set()
        for pre, body in C.spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                s = C.setter_of(el)
                if C.classify(s, inits) == 'INTISH':
                    ks |= set(subclass(s, inits))
        seen[f[:-3]] = ks
        print('  %-16s %s' % (f[:-3], ' '.join(sorted(ks)) or '-'))
    ok = True
    for a, k in sorted(want.items()):
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
        for t in sorted(hits):
            print('   CAND %-40s %s' % (t, ' | '.join(sorted(hits[t]))[:160]))
        print('   CANDIDATES %d' % len(hits))
