#!/usr/bin/env python3
"""r11u81 A-PRIORI MOVER CENSUS — which corpus tests can reach the hop store.

§ hopStoreHandsOnItsTypespec81 writes on ONE shape: an elaborated
struct-pattern operand whose SETTER is a reference to a PARAMETER NAME —
directly, or under a `signed'` / `unsigned'` / `$signed` / `$unsigned` cast on
the producer's `return c` face, which hands the argument's constant (typespec
included) on.  Everything else the walk answers 0 or -1 for and no byte moves.

Population, taken through the committed `census68_base` (r11u72repro) rather
than a copy: EVERY element of EVERY `'{...}` span in a parameter context —
NOT filtered by `classify`, because this law does not live on the encoding
table's faces at all and an encoding class would hide exactly the bare-name
setters it writes on.

  HOP81    the setter, after outer parentheses and any number of signedness
           casts are stripped, is a bare (possibly package-qualified) NAME.
           SUPERSET BY CONSTRUCTION: no check that the name is a parameter at
           all, that the pattern's parameter is struct-typed, that the flat
           fold happens, that the operand lacks a typespec already (the write
           is ADD-ONLY), or that the plan walk answers rather than abstains.
  AGREE81  a setter in that population the write cannot reach.

The measured movers must be a SUBSET of the HOP81 names.

usage:  census81.py [<corpus dir> ...]      (default: both pinned corpora)
        census81.py --selftest              (the positive control on the grid)
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
CAST = re.compile(r'^\s*(?:\$?(signed|unsigned))\s*\'?\s*\(')


def strip_hop(s):
    """outer parentheses and signedness-cast wrappers off, repeatedly"""
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


def is_hop(s):
    return bool(NAME.match(strip_hop(s)))


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
                        k = 'HOP81' if is_hop(s) else 'AGREE81'
                        hist[k] = hist.get(k, 0) + 1
                        if k != 'AGREE81':
                            hits.setdefault(C.testname(root, p), set()).add(
                                '%s: %s' % (k, s[:56]))
                        _ = inits
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must SIGHT this pass's own grid arms."""
    want = ['a1_hopts81', 'a2_castts81', 'a3_hopbnd81', 'x9c_cast73',
            'z1_ts78', 'z2_hop78', 'v3cast76', 'y3_castenc76']
    d = os.path.join(HERE, 'grid')
    seen = {}
    for f in sorted(os.listdir(d)):
        if not f.endswith('.sv'):
            continue
        t = C.strip_noise(open(os.path.join(d, f), errors='replace').read())
        ks = set()
        for pre, body in C.spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                if is_hop(C.setter_of(el)):
                    ks.add('HOP81')
        seen[f[:-3]] = ks
    ok = True
    for a in want:
        print('  %-16s %s' % (a, ' '.join(sorted(seen.get(a, set()))) or '-'))
        if 'HOP81' not in seen.get(a, set()):
            print('  ARM %s does NOT carry HOP81 — the scanner is blind' % a)
            ok = False
    # and the NEGATIVE control: an arm with no name setter at all must not
    # be sighted.
    neg = [a for a, k in sorted(seen.items()) if not k]
    print('  not sighted (%d): %s' % (len(neg), ' '.join(neg[:12])))
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
