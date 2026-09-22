#!/usr/bin/env python3
"""r11u87 A-PRIORI MOVER CENSUS — the DECLARED-TYPE-AWARE lister.

This pass writes on TWO shapes, both of them elaborated struct-pattern
operands whose SETTER names a PARAMETER (directly or under a
`signed'`/`unsigned'`/`$signed`/`$unsigned` cast):

  SGN87  § modHopSignedStoreTs87 — the hop is declared with a SIGNED type of
         one of the three kinds `valueRange` reads (`int`, or anything
         carrying the `signed` keyword: `signed [15:0]`, `logic signed`,
         `bit signed`, `reg signed`, `int signed`), and its home is NOT a
         package.  A typedef'd type is UNRESOLVABLE here, so it counts as a
         candidate.
  DEC87  § modHopStoreSizeIsTheLiteral87 — the hop's chain ends at a `'d`
         literal (`census86.py`'s HOP86D), home not a package.
  UNR87  a NAME setter whose chain cannot be resolved IN FILE, or whose
         declaration text this scanner cannot classify — a candidate BY
         IGNORANCE, so the prediction stays a SUPERSET.
  AGREE87 a setter neither law can reach.

SUPERSET BY CONSTRUCTION, on every axis: a PACKAGE-homed hop is excluded only
when the declaration is found inside a `package … endpackage` span IN THE SAME
FILE; there is no check that the PATTERN is module-homed, that the parameter is
struct-typed, that the hop is not OVERRIDDEN, that the reduce succeeds or that
the flat fold happens at all.  The measured movers must be a SUBSET of the
SGN87 / DEC87 / UNR87 names.

usage:  census87.py [<corpus dir> ...]      (default: the pinned corpora)
        GRID87=<assembled grid> census87.py --selftest    (positive control)
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
# `strip_hop` is r11u86's, taken from the committed file rather than copied
for cand in (os.path.join(HERE, '..', 'r11u86repro'),
             os.path.expanduser(
                 '~/git-repos/slang-uhdm/tools/probe/r11u86repro'), HERE):
    if os.path.isfile(os.path.join(cand, 'census86.py')):
        sys.path.insert(0, cand)
        break

NAME = re.compile(r'^[A-Za-z_]\w*(\s*::\s*[A-Za-z_]\w*)?$')
CAST = re.compile(r"^\s*(?:\$?(signed|unsigned))\s*\'?\s*\(")
BASED = re.compile(r"^\s*\d*\s*'\s*[sS]?([dDhHoObB])[0-9a-fA-FxXzZ_?]+\s*$")
# the declared types `CompileHelper::valueRange` reads as SIGNED
SIGNED_TY = re.compile(r'\bsigned\b')
UNSIGNED_TY = re.compile(r'\bunsigned\b')
INT_TY = re.compile(r'\bint\b')
# the shapes this scanner can classify with certainty as NOT signed
PLAIN_TY = re.compile(r'^\s*(?:var\s+)?(?:logic|bit|reg|byte|shortint|integer'
                      r'|longint|time|real|realtime|string)?\s*'
                      r'(?:\[[^\]]*\]\s*)*$')

from census86 import strip_hop                                 # noqa: E402


def pkg_spans(t):
    """character spans of every `package … endpackage` block"""
    out = []
    for m in re.finditer(r'\bpackage\b', t):
        e = re.search(r'\bendpackage\b', t[m.start():])
        if e:
            out.append((m.start(), m.start() + e.end()))
    return out


def param_decls(t):
    """NAME -> (declared type text, initializer text, in_package)"""
    pk = pkg_spans(t)
    out = {}
    for m in re.finditer(r'\b(?:parameter|localparam)\b([^;]*);', t, re.S):
        inpkg = any(a <= m.start() < b for a, b in pk)
        for part in C.split_top(m.group(1)):
            mm = re.match(r'^(.*?)\b([A-Za-z_]\w*)\s*=\s*(.+)$', part, re.S)
            if mm and "'{" not in mm.group(3):
                out[mm.group(2)] = (mm.group(1), mm.group(3).strip(), inpkg)
    return out


def ty_signed(ty):
    """True / False / None(unknown) for a declaration's type text"""
    if UNSIGNED_TY.search(ty):
        return False
    if SIGNED_TY.search(ty) or INT_TY.search(ty):
        return True
    if PLAIN_TY.match(ty):
        return False
    return None                      # a typedef or a shape not named here


def classify(s, decls):
    """AGREE87 / SGN87 / DEC87 / UNR87 for ONE setter"""
    x = strip_hop(s)
    if not NAME.match(x):
        return 'AGREE87'
    seen = set()
    sgn = False
    for _ in range(8):
        bare = x.split('::')[-1].strip()
        if bare in seen:
            return 'UNR87'
        seen.add(bare)
        if bare not in decls:
            return 'UNR87'                  # unresolved IN FILE — candidate
        ty, init, inpkg = decls[bare]
        if not inpkg:
            sg = ty_signed(ty)
            if sg is None:
                return 'UNR87'              # unclassifiable declaration
            if sg:
                sgn = True                  # LAW A reaches this hop
        nxt = strip_hop(init)
        m = BASED.match(nxt)
        if m:
            if sgn:
                return 'SGN87'
            return 'DEC87' if (m.group(1).lower() == 'd' and not inpkg) \
                else 'AGREE87'
        if not NAME.match(nxt):
            # a plain decimal / an operation leaf: only LAW A can reach it
            return 'SGN87' if sgn else 'AGREE87'
        x = nxt
    return 'UNR87'


def scan(roots):
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
                decls = param_decls(t)
                for pre, body in C.spans(t):
                    if not re.search(r'\b(parameter|localparam)\b', pre):
                        continue
                    for el in C.split_top(body):
                        s = C.setter_of(el)
                        k = classify(s, decls)
                        hist[k] = hist.get(k, 0) + 1
                        if k != 'AGREE87':
                            hits.setdefault(C.testname(root, p), set()).add(
                                '%s: %s' % (k, s[:56]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must SIGHT this pass's own arms."""
    want = {'y1_sgnd87': 'SGN87', 'y4_size87': 'SGN87', 'y5_ovr87': 'SGN87',
            'y7_msc87': 'SGN87', 'z1_decl86': 'SGN87', 'z6_sign86': 'SGN87',
            'z7_trunc86': 'DEC87', 'm2_enc86': 'DEC87'}
    # the arms this control names live in several committed repro dirs; $GRID87
    # points at the assembled grid the pass's own §7 builds (default: the one
    # beside this file, which holds THIS pass's eight arms only)
    d = os.environ.get('GRID87', os.path.join(HERE, 'grid'))
    seen = {}
    for f in sorted(os.listdir(d)):
        if not f.endswith('.sv'):
            continue
        t = C.strip_noise(open(os.path.join(d, f), errors='replace').read())
        decls = param_decls(t)
        ks = set()
        for pre, body in C.spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                k = classify(C.setter_of(el), decls)
                if k != 'AGREE87':
                    ks.add(k)
        seen[f[:-3]] = ks
    ok = True
    for a in sorted(want):
        got = seen.get(a, set())
        print('  %-16s %s' % (a, ' '.join(sorted(got)) or '-'))
        if want[a] not in got:
            print('  ARM %s carries no %s — the scanner is blind'
                  % (a, want[a]))
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
