#!/usr/bin/env python3
"""r11u76 A-PRIORI MOVER CENSUS — which corpus tests can reach THIS pass's two
faces.

Both laws only ever re-spell a cell where the elaborated pattern-operand fold
already runs (r11u66's INTISH / CAST population), so this is r11u73's census
re-subclassified by r11u76's divergence classes:

  SDECVAL  a BASED literal whose WRITTEN DIGITS are worth something other than
           slang's stored `SVInt` — either an `s` marker with the top bit set
           (`8'sd200`, `8'shC8`, `4'sb1111`) or digits that overflow the
           declared width (`4'd20`, `4'hFF`).  LAW A gives the arm the digits.
  SDECREF  the same divergence on the REFUSAL side: digits the producer's
           `NumUtils::parse*` rejects (a decimal past INT64_MAX, a b/o/h past
           uint64) while the stored pattern parses fine.
  SCAST    a `signed'(...)` / `unsigned'(...)` / `$signed(...)` / `$unsigned(...)`
           whose argument (through NAME hops) is a SIZED based literal on the
           producer's `return c` face — LAW B hands back that literal's own
           constant.
  AGREE    an INTISH/CAST setter none of the above can reach

It is a SUPERSET BY CONSTRUCTION: sources only, no check that the pattern's
parameter is struct-typed, that the flat fold happens, that the values actually
diverge at the emitted operand, or that the setter survives the admission
fences.  The measured movers must be a SUBSET of the non-AGREE names.

usage:  census76.py [<corpus dir> ...]      (default: both pinned corpora)
        census76.py --selftest              (the positive control on the grid)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BASEDIR = os.path.join(HERE, '..', 'r11u72repro')
if not os.path.isdir(BASEDIR):
    BASEDIR = os.path.expanduser(
        '~/git-repos/slang-uhdm/tools/probe/r11u72repro')
sys.path.insert(0, BASEDIR)
import census68_base as C          # noqa: E402

INT64_MAX = (1 << 63) - 1
# a SIZED based literal, any base: <width>'[s]<base><digits>
LIT = re.compile(r"(\d+)'([sS]?)([hHbBoOdD])([0-9a-fA-F_]+)")
# a signedness cast in either spelling
SCASTRE = re.compile(r"(signed|unsigned)\s*'\s*\(|\$(signed|unsigned)\s*\(")
BASEN = {'h': 16, 'b': 2, 'o': 8, 'd': 10}


def _digits(base, ds):
    try:
        return int(ds.replace('_', ''), BASEN[base])
    except ValueError:
        return None


def lit_classes(x):
    """the classes a literal SPELLING carries, by the two readings of it"""
    out = set()
    for m in LIT.finditer(x):
        w = int(m.group(1))
        signed = bool(m.group(2))
        base = m.group(3).lower()
        d = _digits(base, m.group(4))
        if d is None or w <= 0:
            continue
        pat = d & ((1 << w) - 1)
        slangv = pat - (1 << w) if (signed and (pat >> (w - 1)) & 1) else pat
        if d != slangv:
            out.add('SDECVAL')
        # the refusal half: the producer's parser on the DIGITS vs on the
        # stored pattern.  decimal is strict-int64, b/o/h are lenient-uint64
        # under a declared-width guard.
        lim = INT64_MAX if base == 'd' else (1 << 64) - 1
        dref = d > lim or (base != 'd' and w > 64)
        pref = abs(slangv) > lim or (base != 'd' and w > 64)
        if dref != pref:
            out.add('SDECREF')
    return out


def scast_passthru(x, inits, depth=0):
    """a signedness cast whose argument (through NAME hops) is a SIZED based
    literal on the producer's `return c` face"""
    if depth > 6:
        return False
    for m in SCASTRE.finditer(x):
        sgn = (m.group(1) or m.group(2)).lower() == 'signed'
        # the argument text: from the '(' to its matching ')'
        i = x.find('(', m.start())
        if i < 0:
            continue
        d = 0
        j = i
        while j < len(x):
            if x[j] == '(':
                d += 1
            elif x[j] == ')':
                d -= 1
                if d == 0:
                    break
            j += 1
        a = x[i + 1:j].strip()
        for _ in range(8):
            if a in inits:
                a = inits[a].strip()
            else:
                break
        lm = LIT.fullmatch(a.replace(' ', ''))
        if not lm:
            continue
        base = lm.group(3).lower()
        if sgn and base != 'd':
            continue          # $signed on h/b/o MINTS — not this law
        return True
    # through a NAME hop onto a parameter whose own init is such a cast
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm in inits and scast_passthru(inits[nm], inits, depth + 1):
            return True
    return False


def name_expand(x, inits, depth=0):
    """the setter text with one level of NAME initializers pasted in, to the
    depth the reduce follows"""
    if depth > 6:
        return x
    out = [x]
    for m in re.finditer(r'\b([A-Za-z_]\w*)\b', x):
        nm = m.group(1)
        if nm in inits:
            out.append(name_expand(inits[nm], inits, depth + 1))
    return ' '.join(out)


def subclass(x, inits):
    out = set(lit_classes(name_expand(x, inits)))
    if scast_passthru(x, inits):
        out.add('SCAST')
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
                        # LAW A fires where the value table is read (INTISH)
                        # and LAW B where the cast arm runs (CAST); a BASED or
                        # NAME leaf standing alone is operand-0 verbatim, which
                        # neither law touches.
                        if c not in ('INTISH', 'CAST'):
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
    want = {'y1_sdval76': 'SDECVAL', 'y2_digits76': 'SDECVAL',
            'y4_pos76': 'SDECREF', 'y3_castenc76': 'SCAST',
            'x1_sdec73': 'SDECVAL', 'x7_sdecpos73': 'SDECVAL'}
    seen = {}
    # VERIFIER FIX (r11v76) — two of the six control arms (`x1_sdec73`,
    # `x7_sdecpos73`) are COMMITTED IN r11v73repro, not here, so a selftest
    # that reads only this directory prints `SELFTEST FAIL` on the committed
    # tree even though the scanner is fine.  Read both grids.
    dirs = [os.path.join(HERE, 'grid'),
            os.path.join(HERE, '..', 'r11v73repro', 'grid')]
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
                if C.classify(s, inits) in ('INTISH', 'CAST'):
                    ks |= set(subclass(s, inits))
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
        print('   CANDIDATES %d' % len(hits))
        for t in sorted(hits):
            for h in sorted(hits[t]):
                print('     %-44s %s' % (t, h))
