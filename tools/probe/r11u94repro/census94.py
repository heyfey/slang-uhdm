#!/usr/bin/env python3
"""r11u94 A-PRIORI MOVER CENSUS — two classes, one per law, each a STRICT
SUPERSET of the gate that lands, plus a POSITIVE CONTROL that proves the
scanner can see and a NEGATIVE one that proves it can miss.

  PKS94  § pkgImplicitSynIsAnInt94 (LAW A) — a PACKAGE-homed parameter whose
         declaration is IMPLICIT and wears a SIGNING KEYWORD or a PACKED
         DIMENSION.  That is the shape `red91PkgDeclKind91` used to refuse
         with -1 and now answers with kind 2.  Superset: nothing here checks
         that the parameter is READ, that the reader is a module-homed hop
         with a declared type, that the read is written `pkg::NAME`, that the
         leaf is a `'d` literal or that the read reaches a `'{…}` pattern.
  PKSW94 the same class with the DIMENSION arm alone dropped — reported beside
         PKS94 so the two arms of the synthesiser are separate numbers.
  MIN94  § pkgParamMinusIsIntReduce94 (LAWS B and C) — a PACKAGE-homed
         parameter whose initializer's TOP-LEVEL operator is a unary minus or
         a binary subtraction.  Superset: nothing checks that the parameter is
         read through the package-parameter fold, that the reduce succeeds, or
         the sign of the answer.
  MINW94 ANY minus anywhere in the initializer text — a superset of MIN94 in
         turn, so the hole between the written shape and the parsed one is a
         number and not a claim.

Both classes are FILE-keyed (a declaration, not a `'{…}` setter): these laws
fire wherever the parameter is READ, which is not a span population at all.

usage:  census94.py [<corpus dir> ...]      (default: the pinned corpora)
        census94.py --selftest              (the positive control)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
for sib in ('r11u87repro',):
    for cand in (os.path.join(HERE, '..', sib),
                 os.path.expanduser(
                     '~/git-repos/slang-uhdm/tools/probe/' + sib)):
        if os.path.isdir(cand):
            sys.path.insert(0, cand)
            break
import census87 as S                                           # noqa: E402
C = S.C

WORD = re.compile(r'[A-Za-z_]\w*')
DECL = re.compile(r'\b(?:parameter|localparam)\b([^;]*);', re.S)
NOTTY = ('signed', 'unsigned', 'var', 'localparam', 'parameter', 'type')


def decls94(t):
    """(name, type text, initializer text) for every PACKAGE-homed parameter.

    The type text LEADS a comma list, so it is carried forward to every
    element of the same declaration — `localparam signed A = 1, B = 2` gives
    both A and B the `signed` declaration, which `param_decls` does not.
    """
    pk = S.pkg_spans(t)
    out = []
    for m in DECL.finditer(t):
        if not any(a <= m.start() < b for a, b in pk):
            continue
        lead = None
        for part in C.split_top(m.group(1)):
            mm = re.match(r'^(.*?)\b([A-Za-z_]\w*)\s*=\s*(.+)$', part, re.S)
            if not mm:
                continue
            ty = mm.group(1)
            if lead is None:
                lead = ty
            elif not ty.strip():
                ty = lead
            out.append((mm.group(2), ty, mm.group(3).strip()))
    return out


def syn94(ty):
    """(implicit + signing, implicit + a packed dimension)"""
    bare = re.sub(r'\[[^\]]*\]', ' ', ty)
    words = [w for w in WORD.findall(bare)]
    if [w for w in words if w not in NOTTY]:
        return (False, False)          # a WRITTEN data type — kind 1
    signing = any(w in ('signed', 'unsigned') for w in words)
    dim = bool(re.search(r'\[[^\]]*\]', ty))
    return (signing, dim)


def min94(init):
    """the initializer's TOP-LEVEL operator is `-` (unary) or `a - b`"""
    s = init.strip()
    if s.startswith('-'):
        return True
    d = 0
    for i, ch in enumerate(s):
        if ch in '([{':
            d += 1
        elif ch in ')]}':
            d -= 1
        elif ch == '-' and d == 0:
            if i + 1 < len(s) and s[i + 1] == '>':
                continue
            j = i - 1
            while j >= 0 and s[j].isspace():
                j -= 1
            if j >= 0 and (s[j].isalnum() or s[j] in "_)]}'"):
                return True
    return False


def tags94(name, ty, init):
    out = set()
    sg, dm = syn94(ty)
    if sg or dm:
        out.add('PKS94')
    if sg:
        out.add('PKSW94')
    if min94(init):
        out.add('MIN94')
    if '-' in init:
        out.add('MINW94')
    return out


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
                for nm, ty, init in decls94(t):
                    tg = tags94(nm, ty, init)
                    if not tg:
                        hist['AGREE94'] = hist.get('AGREE94', 0) + 1
                        continue
                    for k in tg:
                        hist[k] = hist.get(k, 0) + 1
                    hits.setdefault(name, set()).add(
                        '%s: %s = %s' % ('+'.join(sorted(tg)), nm, init[:40]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must sight this pass's own arms, and
    must LEAVE SOMETHING UNSIGHTED."""
    want = {'q1_pkgsyn94': 'PKS94', 'q2_pkgbase94': 'PKS94',
            'q3_pkgread94': 'PKS94', 'q4_negpkg94': 'MIN94',
            'q5_negedge94': 'MIN94', 'q6_negwid94': 'MIN94',
            'p4_pkghome91': 'PKS94'}
    d = os.path.join(HERE, 'grid')
    P = os.path.join(HERE, '..')
    files = [os.path.join(d, f) for f in sorted(os.listdir(d))
             if f.endswith('.sv')]
    for rel in ('r11u91repro/grid/p4_pkghome91.sv',
                'r11u91repro/grid/p1_pkgin91.sv',
                'r11v91repro/grid/v5_road2way91.sv',
                'r11u87repro/grid/y1_sgnd87.sv'):
        q = os.path.join(P, rel)
        if os.path.isfile(q):
            files.append(q)
    seen = {}
    for q in files:
        t = C.strip_noise(open(q, errors='replace').read())
        ks = set()
        for nm, ty, init in decls94(t):
            ks |= tags94(nm, ty, init)
        seen[os.path.basename(q)[:-3]] = ks
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
    # THE LIVE NEGATIVE CONTROL: a package parameter with a WRITTEN data type
    # and no minus must be sighted by NEITHER class, and the shapes the laws
    # decline (an explicit cast over a subtraction, a `+`, a shift) must not
    # reach MIN94.
    live = ('package z; localparam int A = 3; localparam logic [7:0] B = 5;\n'
            '  localparam logic [7:0] C = 8\'(5 - 8); localparam int D = 1 + 2;\n'
            '  localparam int E = -1 <<< 1; localparam signed F = 5;\n'
            '  localparam int G = 0 - 3; endpackage\n')
    lk = {nm: tags94(nm, ty, init)
          for nm, ty, init in decls94(C.strip_noise(live))}
    for nm, must in (('A', set()), ('B', set()), ('D', set()),
                     ('F', {'PKS94', 'PKSW94'}),
                     ('G', {'MIN94', 'MINW94'})):
        got = lk.get(nm, set())
        print('  live %-3s %s' % (nm, ' '.join(sorted(got)) or '-'))
        if got != must:
            print('  live control %s: expected %s' % (nm, sorted(must) or '-'))
            ok = False
    if 'MIN94' in lk.get('C', set()):
        print('  live control C: an explicit cast reached MIN94')
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
    # THE ROOTS ARE THE SWEEP'S OWN.  `verify_golden.py:50` reads
    # `UHDM2RTLIL_TESTS = ~/git-repos/uhdm2rtlil/test` — SINGULAR — and
    # `~/git-repos/uhdm2rtlil/tests` DOES NOT EXIST, so every census invoked
    # with the inherited default (census87 through census91, and the
    # invocation printed in r11u91repro/README.md §7) walked an empty path for
    # the whole uhdm2rtlil corpus and reported a number for the Surelog corpus
    # alone.  That hole is what hid `ibex_icache` from this pass's first
    # prediction; it is recorded as an instrument residue and fixed here.
    roots = sys.argv[1:] or [
        os.path.expanduser('~/git-repos/uhdm2rtlil/test'),
        os.path.expanduser('~/git-repos/Surelog/tests'),
        os.path.expanduser('~/git-repos/Surelog/third_party/tests'),
    ]
    hits, hist = scan(roots)
    for k in sorted(hist):
        print('%-10s %d' % (k, hist[k]))
    print('--- candidate tests: %d' % len(hits))
    for t in sorted(hits):
        for h in sorted(hits[t]):
            print('  %-34s %s' % (t, h))
