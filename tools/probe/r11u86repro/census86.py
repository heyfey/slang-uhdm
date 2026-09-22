#!/usr/bin/env python3
"""r11u86 A-PRIORI MOVER CENSUS — the DEC-AWARE lister.

§ modPatHopValueStoreEnc86 writes on ONE shape: an elaborated struct-pattern
operand whose SETTER is a reference to a PARAMETER NAME (directly, or under a
`signed'`/`unsigned'`/`$signed`/`$unsigned` cast on the producer's `return c`
face) AND whose hop chain ends at a `'d`- or `'o`-BASED literal.  Every other
spelling — `'h`, `'b`, a plain decimal, an operation, a direct literal — is
left exactly as the pristine binary wrote it.

Population, taken through the committed `census68_base` (r11u72repro) rather
than a copy: EVERY element of EVERY `'{...}` span in a parameter context, NOT
filtered by `classify`.

  HOP86D   name setter whose in-file initializer CHAIN ends at a `'d`/`'sd`
           literal
  HOP86O   … at an `'o`/`'so` literal
  HOP86U   a NAME setter whose chain cannot be resolved IN FILE — a candidate
           BY IGNORANCE, so the prediction stays a superset
  AGREE86  a setter the write cannot reach: a non-name, or a name whose chain
           ends at `'h`/`'b`/a plain decimal/an expression

SUPERSET BY CONSTRUCTION: no check that the PATTERN is module-homed (the law's
first gate), that the literal is <= 64 bits, that the reduce succeeds, that the
pattern's parameter is struct-typed, or that the flat fold happens at all.
The measured movers must be a SUBSET of the HOP86D/O/U names.

usage:  census86.py [<corpus dir> ...]      (default: both pinned corpora)
        census86.py --selftest              (the positive control on the grid)
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

NAME = re.compile(r'^[A-Za-z_]\w*(\s*::\s*[A-Za-z_]\w*)?$')
CAST = re.compile(r"^\s*(?:\$?(signed|unsigned))\s*\'?\s*\(")
BASED = re.compile(r"^\s*\d*\s*'\s*[sS]?([dDhHoObB])[0-9a-fA-FxXzZ_?]+\s*$")


def strip_hop(s):
    x = s.strip()
    for _ in range(8):
        y = x
        while x.startswith('(') and x.endswith(')'):
            d, ok = 0, True
            for i, ch in enumerate(x):
                if ch == '(':
                    d += 1
                elif ch == ')':
                    d -= 1
                    if d == 0 and i != len(x) - 1:
                        ok = False
                        break
            if not ok:
                break
            x = x[1:-1].strip()
        m = CAST.match(x)
        if m:
            i = x.find('(')
            d, j = 0, i
            while j < len(x):
                if x[j] == '(':
                    d += 1
                elif x[j] == ')':
                    d -= 1
                    if d == 0:
                        break
                j += 1
            if j < len(x) and x[j + 1:].strip() == '':
                x = x[i + 1:j].strip()
        if x == y:
            break
    return x


def classify(s, inits):
    """AGREE86 / HOP86D / HOP86O / HOP86U for ONE setter"""
    x = strip_hop(s)
    if not NAME.match(x):
        return 'AGREE86'
    seen = set()
    for _ in range(8):
        bare = x.split('::')[-1].strip()
        if bare in seen:
            return 'HOP86U'
        seen.add(bare)
        if bare not in inits:
            return 'HOP86U'            # unresolved IN FILE — candidate
        nxt = strip_hop(inits[bare])
        m = BASED.match(nxt)
        if m:
            b = m.group(1).lower()
            return ('HOP86D' if b == 'd' else
                    'HOP86O' if b == 'o' else 'AGREE86')
        if not NAME.match(nxt):
            return 'AGREE86'           # an expression / plain decimal leaf
        x = nxt
    return 'HOP86U'


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
                        k = classify(s, inits)
                        hist[k] = hist.get(k, 0) + 1
                        if k != 'AGREE86':
                            hits.setdefault(C.testname(root, p), set()).add(
                                '%s: %s' % (k, s[:56]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must SIGHT this pass's own grid arms."""
    want = ['m1_route86', 'm2_enc86', 'm3_gate86', 'm4_ctx86', 'm5_bnd86',
            'm6_ov86']
    d = os.path.join(HERE, 'grid')
    seen = {}
    for f in sorted(os.listdir(d)):
        if not f.endswith('.sv'):
            continue
        t = C.strip_noise(open(os.path.join(d, f), errors='replace').read())
        inits = C.param_inits(t)
        ks = set()
        for pre, body in C.spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                k = classify(C.setter_of(el), inits)
                if k != 'AGREE86':
                    ks.add(k)
        seen[f[:-3]] = ks
    ok = True
    for a in want:
        print('  %-16s %s' % (a, ' '.join(sorted(seen.get(a, set()))) or '-'))
        if not ({'HOP86D', 'HOP86O'} & seen.get(a, set())):
            print('  ARM %s carries no HOP86D/O — the scanner is blind' % a)
            ok = False
    neg = [a for a, k in sorted(seen.items()) if not k]
    print('  not sighted (%d): %s' % (len(neg), ' '.join(neg[:12])))
    if not neg:
        print('  NEGATIVE CONTROL VACUOUS — no arm is unsighted')
        ok = False
    print('SELFTEST ' + ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--selftest':
        sys.exit(selftest())
    roots = sys.argv[1:] or [
        os.path.expanduser('~/git-repos/uhdm2rtlil/tests'),
        os.path.expanduser('~/git-repos/Surelog/tests'),
    ]
    hits, hist = scan(roots)
    for k in sorted(hist):
        print('%-10s %d' % (k, hist[k]))
    print('--- candidate tests: %d' % len(hits))
    for t in sorted(hits):
        for h in sorted(hits[t]):
            print('  %-34s %s' % (t, h))
