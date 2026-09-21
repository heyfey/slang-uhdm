#!/usr/bin/env python3
"""r11u73 A-PRIORI MOVER CENSUS — which corpus tests can reach THIS pass's four
faces.

The laws only ever re-spell a cell where § patOperandEncReduceTable66 /
§ caSubstLeafEncReduceTable56 already fire (r11u66's INTISH class) or where a
§ patBailStopsMemberStamp68 bail has already moved a size.  So this is r11u72's
census, re-subclassified by THIS pass's divergence classes:

  POW      a `**` whose result can leave int64 — LAW A's new render is the
           `static_cast` artefact `INT:-9223372036854775808`, and its NEGATIVE
           sign also makes `get_uvalue` refuse, so the bail can move too
  DECWIDE  a based-DECIMAL literal whose magnitude exceeds INT64_MAX, reachable
           through NAME hops — LAW C makes the arm REFUSE where we folded
  UNTCHAIN an untyped `localparam` whose initializer is an operator/cast (or a
           NAME chain onto one) — LAW D stamps 32 where slang's width differs
  AGREE    an INTISH setter none of the above can reach

It is a SUPERSET BY CONSTRUCTION: sources only, no check that the pattern's
parameter is struct-typed, that the flat fold happens, that the values actually
diverge, or that the setter survives the admission fences.  The measured movers
must be a SUBSET of the non-AGREE names.

usage:  census73.py [<corpus dir> ...]      (default: both pinned corpora)
        census73.py --selftest              (the positive control on the grid)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'r11u72repro'))
import census68_base as C          # noqa: E402
import census72 as C72             # noqa: E402

# a based DECIMAL literal: `<width>'[s]d<digits>`
DECLIT = re.compile(r"(\d+)'[sS]?[dD]([0-9_]+)")
# an untyped localparam/parameter declaration: no type keyword, no dimensions
UNTYPED = re.compile(r'\b(?:localparam|parameter)\s+([A-Za-z_]\w*)\s*=')
OPCHARS = re.compile(r"[-+*/%<>&|^~]|'\s*\(|\)\s*'")


def pow_escapes(x, inits, depth=0):
    """a `**` arm whose value can leave int64.  Superset: ANY `**` counts
    unless both operands are literals whose power provably fits."""
    if depth > 6:
        return False
    if '**' in x:
        for m in re.finditer(r'(\w+)\s*\*\*\s*(\w+)', x):
            a, b = m.group(1), m.group(2)
            if a.isdigit() and b.isdigit():
                try:
                    if int(a) ** int(b) < (1 << 63):
                        continue
                except (ValueError, OverflowError):
                    pass
            return True
        return True
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm in inits and pow_escapes(inits[nm], inits, depth + 1):
            return True
    return False


def dec_wide(x, inits, depth=0):
    """a based-DECIMAL leaf beyond INT64_MAX, through NAME hops"""
    for m in DECLIT.finditer(x):
        try:
            if int(m.group(2).replace('_', '')) > (1 << 63) - 1:
                return True
        except ValueError:
            pass
    if depth > 6:
        return False
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm in inits and dec_wide(inits[nm], inits, depth + 1):
            return True
    return False


def unt_chain(x, inits, untyped, depth=0):
    """a NAME leaf that is an UNTYPED parameter whose initializer (possibly
    through further NAME hops) is an operator or a cast — the constant the
    producer MINTS, which it re-stamps at 32"""
    if depth > 6:
        return False
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm not in inits:
            continue
        init = inits[nm]
        if nm in untyped and OPCHARS.search(init):
            return True
        if unt_chain(init, inits, untyped, depth + 1):
            return True
    return False


def untyped_names(t):
    return set(UNTYPED.findall(t))


def subclass(x, inits, untyped):
    out = []
    if pow_escapes(x, inits):
        out.append('POW')
    if dec_wide(x, inits):
        out.append('DECWIDE')
    if unt_chain(x, inits, untyped):
        out.append('UNTCHAIN')
    return out or ['AGREE']


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
                untyped = untyped_names(t)
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
                        for k in subclass(s, inits, untyped):
                            hist['@' + k] = hist.get('@' + k, 0) + 1
                            if k != 'AGREE':
                                hits.setdefault(
                                    C.testname(root, p), set()).add(
                                        '%s: %s' % (k, s[:56]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must SIGHT each law's own grid arm."""
    want = {'w1_pow73': 'POW', 'w2_powbail73': 'POW',
            'w3_dec73': 'DECWIDE', 'w4_hop73': 'UNTCHAIN',
            'w7_untw73': 'UNTCHAIN', 't7_fence72': 'POW'}
    seen = {}
    for d, arms in ((os.path.join(HERE, 'grid'), None),
                    (os.path.join(HERE, '..', 'r11u72repro', 'grid'), None)):
        for f in sorted(os.listdir(d)):
            if not f.endswith('.sv'):
                continue
            t = C.strip_noise(open(os.path.join(d, f), errors='replace').read())
            inits = C.param_inits(t)
            untyped = untyped_names(t)
            ks = set()
            for pre, body in C.spans(t):
                if not re.search(r'\b(parameter|localparam)\b', pre):
                    continue
                for el in C.split_top(body):
                    s = C.setter_of(el)
                    if C.classify(s, inits) == 'INTISH':
                        ks |= set(subclass(s, inits, untyped))
            seen[f[:-3]] = ks
            if f[:-3] in want:
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
    # r11u72's own classes, re-run unchanged as the corroborating half
    print('== r11u72 CLASSES (unchanged scanner)')
    for loose in (False, True):
        h2, hi2 = C72.scan(roots, loose)
        print('   %-6s %s' % ('LOOSE' if loose else 'STRICT',
                              ' '.join('%s=%d' % (k[1:], hi2[k])
                                       for k in sorted(hi2)
                                       if k.startswith('@'))))
        print('   CANDIDATES %d' % len(h2))
