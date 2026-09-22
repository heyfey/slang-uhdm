#!/usr/bin/env python3
"""r11u91 A-PRIORI MOVER CENSUS — census89.py RE-KEYED ON THE GATE'S OWN READ,
plus one class per law this pass lands.

r11v89's RV89-3: `census89.classify89` asks `not inpkg` at the hop whose
INITIALIZER is the literal, while the landed gate
(`§ modWideModuleStoreEnc89`, `ParamEmit.cpp`) reads
`red87HopHomeIsInstance87(*hw86)` — the home of the IMMEDIATE hop, the one
`red86HopName86` resolved from the setter.  A MODULE hop whose digits arrive
from a PACKAGE-homed 96-bit literal is therefore INVISIBLE to the census and
VISIBLE to the law, so the a-priori mover set was not a strict superset on
that axis.  `WID91` below is the same class keyed the gate's way; `WIDL89` is
the old literal-keyed reading, reported beside it so the hole's size is a
number and not a claim.

The classes:

  WID91  § modWideModuleStoreEnc89 — the IMMEDIATE hop is NOT package-homed
         and its chain ends at a `'d`/`'o` literal written wider than 64 bits.
         A STRICT SUPERSET of the landed gate (nothing here checks the
         pattern's home, the reduce, the bail index or the operand's
         const type).
  WIDL89 the pass-88 reading of the same class, keyed on the LITERAL's home.
         WID91 - WIDL89 is RV89-3's hole.
  PKI91  § modPkgFedHopStore91 (LAW A) — the immediate hop is NOT
         package-homed, carries a declared type, and its initializer is a BARE
         NAME resolving to a PACKAGE-homed parameter.  Superset: nothing
         checks the base of the package hop's leaf, the reader's const type or
         the pattern's home.
  NEG91  § pkgParamNegFoldIsInt91 (LAW B) — a PACKAGE-homed parameter whose
         initializer text is a NEGATION.  This class is FILE-keyed, not
         setter-keyed: the law fires wherever such a parameter is READ through
         the package-parameter fold (a net-decl-assign, a written assign, an
         index), which is not a `'{…}` span population at all.  Superset:
         nothing checks that the file reads the parameter, that the read is in
         a folding context, or that the value is signed-negative.
  CHN89 / OVR89 / SGN87 / DEC87 / UNR87 — the landed classes, unchanged.

usage:  census91.py [<corpus dir> ...]      (default: the pinned corpora)
        GRID91=<assembled grid> census91.py --selftest   (positive control)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
for sib in ('r11u89repro', 'r11u87repro'):
    for cand in (os.path.join(HERE, '..', sib),
                 os.path.expanduser(
                     '~/git-repos/slang-uhdm/tools/probe/' + sib)):
        if os.path.isdir(cand):
            sys.path.insert(0, cand)
            break
import census89 as N                                           # noqa: E402
import census87 as S                                           # noqa: E402
C = S.C

NEGINIT = re.compile(r'^\s*-\s*[^-]')
# THE WIDE KEY.  A constant expression reaches a NEGATIVE signed value through
# a unary or binary minus, a bitwise NOT, or an explicit `$signed`/`signed'`
# re-reading of a wide unsigned; a package parameter whose initializer text
# holds none of those three cannot fold negative, so this is a superset of the
# law's own `isSigned() && isNegative()` gate.  `->` is excluded (an
# implication / a member access, never an arithmetic minus).
NEGWIDE = re.compile(r"(?<![-\w])-(?!>)|~|\$?\bsigned\b\s*[('](?!\s*\))")


def pkg_neg_params(t, wide=False):
    """package-homed parameters whose initializer could fold NEGATIVE

    wide=False: the initializer text IS a negation (the law's own shape)
    wide=True:  the initializer text COULD fold negative (the superset)
    """
    pk = S.pkg_spans(t)
    out = set()
    for m in re.finditer(r'\b(?:parameter|localparam)\b([^;]*);', t, re.S):
        if not any(a <= m.start() < b for a, b in pk):
            continue
        for part in C.split_top(m.group(1)):
            mm = re.match(r'^(.*?)\b([A-Za-z_]\w*)\s*=\s*(.+)$', part, re.S)
            if not mm:
                continue
            init = mm.group(3).strip()
            if NEGWIDE.search(init) if wide else NEGINIT.match(init):
                out.add(mm.group(2))
    return out


def classify91(s, decls, ports, has_inst):
    """the SET of tags for ONE setter — census89's, re-keyed, plus PKI91"""
    tags = N.classify89(s, decls, ports, has_inst)
    if 'WID89' in tags:
        tags.discard('WID89')
        tags.add('WIDL89')
    x = S.strip_hop(s)
    if not S.NAME.match(x):
        return tags
    seen = set()
    hops = 0
    inpkg0 = None
    for _ in range(8):
        bare = x.split('::')[-1].strip()
        if bare in seen or bare not in decls:
            return tags
        seen.add(bare)
        ty, init, inpkg = decls[bare]
        if hops == 0:
            inpkg0 = inpkg
        nxt = S.strip_hop(init)
        m = S.BASED.match(nxt)
        if m:
            # THE GATE'S OWN READ: the IMMEDIATE hop's home, not this one's.
            if not inpkg0 and m.group(1).lower() in ('d', 'o') \
                    and N.written_width(nxt) > 64:
                tags.add('WID91')
            return tags
        if not S.NAME.match(nxt):
            return tags
        if hops == 0 and not inpkg0 and '::' not in nxt \
                and nxt in decls and decls[nxt][2]:
            tags.add('PKI91')          # the next hop is PACKAGE-homed
        if hops == 0 and not inpkg0 and '::' in nxt:
            tags.add('PKI91')          # a package-QUALIFIED next hop
        x = nxt
        hops += 1
    return tags


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
                name = C.testname(root, p)
                nw = pkg_neg_params(t, wide=True)
                nn = pkg_neg_params(t)
                for q in sorted(nw):
                    k = 'NEG91' if q in nn else 'NEGW91'
                    hist[k] = hist.get(k, 0) + 1
                    hits.setdefault(name, set()).add('%s: %s' % (k, q[:56]))
                if "'{" not in t:
                    continue
                decls = S.param_decls(t)
                ports = N.port_param_names(t)
                has_inst = bool(N.PORTHDR.search(t))
                for pre, body in C.spans(t):
                    if not re.search(r'\b(parameter|localparam)\b', pre):
                        continue
                    for el in C.split_top(body):
                        s = C.setter_of(el)
                        tags = classify91(s, decls, ports, has_inst)
                        if not tags:
                            hist['AGREE91'] = hist.get('AGREE91', 0) + 1
                            continue
                        for k in tags:
                            hist[k] = hist.get(k, 0) + 1
                        hits.setdefault(name, set()).add(
                            '%s: %s' % ('+'.join(sorted(tags)), s[:56]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must SIGHT this pass's own arms and the
    landed ones it inherits, and must LEAVE SOMETHING UNSIGHTED."""
    want = {'p1_pkgin91': 'PKI91', 'p2_pkgedge91': 'PKI91',
            'p3_pkgsize91': 'PKI91', 'p4_pkghome91': 'PKI91',
            'x5_pkgchn89': 'WID91',            # RV89-3's own witness
            'w3_chain87': 'CHN89', 'w9_wide89': 'WID91',
            'w5_ovr87': 'OVR89', 'y1_sgnd87': 'SGN87'}
    # This pass's own arms live beside this file; the landed ones stay in
    # THEIR committed directories rather than being copied here, so the
    # selftest reads the same bytes the passes that landed them measured.
    d = os.environ.get('GRID91', os.path.join(HERE, 'grid'))
    P = os.path.join(HERE, '..')
    files = [os.path.join(d, f) for f in sorted(os.listdir(d))
             if f.endswith('.sv')]
    for rel in ('r11v89repro/grid/x5_pkgchn89.sv',
                'r11u89repro/grid/w3_chain87.sv',
                'r11u89repro/grid/w9_wide89.sv',
                'r11u89repro/grid/w5_ovr87.sv',
                'r11u87repro/grid/y1_sgnd87.sv',
                'r11u81repro/grid/a1_hopts81.sv',
                'r11u81repro/grid/a3_hopbnd81.sv',
                'r11u86repro/grid/b1_pin86.sv'):
        q = os.path.join(P, rel)
        if os.path.isfile(q):
            files.append(q)
    seen = {}
    for q in files:
        f = os.path.basename(q)
        t = C.strip_noise(open(q, errors='replace').read())
        decls = S.param_decls(t)
        ports = N.port_param_names(t)
        has_inst = bool(N.PORTHDR.search(t))
        ks = set()
        for q in pkg_neg_params(t):
            ks.add('NEG91')
        for q in pkg_neg_params(t, wide=True):
            ks.add('NEGW91')
        for pre, body in C.spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                ks |= classify91(C.setter_of(el), decls, ports, has_inst)
        seen[f[:-3]] = ks
    ok = True
    for a in sorted(want):
        got = seen.get(a, set())
        print('  %-16s %s' % (a, ' '.join(sorted(got)) or '-'))
        if a not in seen:
            print('  ARM %s not in the grid' % a)
            ok = False
        elif want[a] not in got:
            print('  ARM %s carries no %s — the scanner is blind'
                  % (a, want[a]))
            ok = False
    # THE RE-KEY IS THE POINT, and it is a PER-SETTER claim: x5_pkgchn89
    # holds BOTH a package-fed wide hop (census89's documented blind spot) and
    # a direct module-homed one (which the old key sights), so the arm-level
    # tag set proves nothing.  At least one SETTER must carry WID91 and NOT
    # WIDL89, and the old key must still sight the direct one.
    hole, kept = 0, 0
    f5 = os.path.join(P, 'r11v89repro/grid/x5_pkgchn89.sv')
    if os.path.isfile(f5):
        t5 = C.strip_noise(open(f5, errors='replace').read())
        d5 = S.param_decls(t5)
        p5 = N.port_param_names(t5)
        i5 = bool(N.PORTHDR.search(t5))
        for pre, body in C.spans(t5):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in C.split_top(body):
                ks = classify91(C.setter_of(el), d5, p5, i5)
                if 'WID91' in ks and 'WIDL89' not in ks:
                    hole += 1
                if 'WID91' in ks and 'WIDL89' in ks:
                    kept += 1
    print('  RV89-3 hole: %d setters WID91-only, %d sighted by both'
          % (hole, kept))
    if hole == 0 or kept == 0:
        print('  the re-key is not a measurement on this grid')
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
