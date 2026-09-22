#!/usr/bin/env python3
"""r11u100 A-PRIORI MOVER CENSUS — three classes, one per law, each a STRICT
SUPERSET of the gate that lands, with a POSITIVE CONTROL that proves the
scanner can see and a LIVE NEGATIVE one that proves it can miss.

  POW100  § powTopIsIntReduce100 (LAW A) — a PACKAGE-homed parameter whose
          initializer's TOP-LEVEL operator is `**`.  Superset: nothing here
          checks that the parameter is READ through the package-parameter
          fold or that `red72Int64` succeeds.  EVERY cell of this class moves
          when it is read: the const type goes 9 -> 7 whatever the magnitude,
          which is why this class alone predicts LAW A's rows.
  POWW100 ANY `**` anywhere in a package parameter's initializer — a superset
          of POW100 in turn, so the hole between the written shape and the
          parsed one is a number and not a claim.

  UAR100  § uintArmWrittenDigitsMasked100 (LAW B) — a PACKAGE-homed parameter
          whose initializer's TOP-LEVEL operator is one of `+`, `&`, `|`,
          `<<`, `>>`, `<<<`, `>>>`.  Superset: nothing checks whether the
          producer's digits and slang's store actually DIFFER.
  UARW100 ANY of those seven operators anywhere in an initializer.

  BARE100 § bareUnsizedDecIsMaskedDigits100 (LAW C) — a PACKAGE-homed
          parameter whose initializer, outer parentheses peeled, is a BARE
          unsized DECIMAL literal.
  BNAM100 the NAME hop of the same law — the initializer is a bare NAME.
          Superset by a mile: the hop only carries when that name's own
          initializer is itself a bare unsized decimal.

  THE THREE DIGIT SOURCES — what makes a UAR100 or a BARE100 cell MOVE at all.
  Both laws write digits that differ from `cv`'s only where the producer's
  reading of a LEAF differs from slang's store:
  UDC100  an unsized decimal literal worth 2**31 or more (r11u96's LAW B; the
          threshold is 2^31, NOT 2^32 — slang types the literal `int`).
  UNBO100 a `'0` / `'1` as an OPERAND (r11u97's LAW A).
  BWL100  a BASED literal whose written digits do not fit its own width
          (r11u76's LAW).
  A row carrying a UAR100 or BARE100 shape but NONE of these three can only
  write the digits it already wrote.  The prediction is reported both ways.

`^`, `&&`, `||`, `!`, `?:`, `===` and `!==` are DELIBERATELY out of every
class: `vpiBitXorOp` has NO arm in `reduceExpr` at all (golden leaves it
unfolded, measured), and the logical and ternary arms are a different body.
The live negative control proves the scanner leaves all of them alone.

usage:  census100.py [<corpus dir> ...]      (default: the pinned corpora)
        census100.py --selftest              (the controls)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
for sib in ('r11u97repro', 'r11u96repro', 'r11u94repro', 'r11u87repro'):
    for cand in (os.path.join(HERE, '..', sib),
                 os.path.expanduser(
                     '~/git-repos/slang-uhdm/tools/probe/' + sib)):
        if os.path.isdir(cand):
            sys.path.insert(0, cand)
            break
import census97 as Q                                           # noqa: E402
import census96 as S                                           # noqa: E402

N = Q.N
C = Q.C
peel100 = Q.peel97
BARELIT = re.compile(r'^\d[\d_]*$')


def _toplevel(s, toks):
    """the first of `toks` at depth 0 in `s`, longest first, or None."""
    d = 0
    i = 0
    n = len(s)
    order = sorted(toks, key=len, reverse=True)
    while i < n:
        ch = s[i]
        if ch in '([{':
            d += 1
            i += 1
            continue
        if ch in ')]}':
            d -= 1
            i += 1
            continue
        if ch == '"':
            i += 1
            while i < n and s[i] != '"':
                i += 2 if s[i] == '\\' else 1
            i += 1
            continue
        if ch == "'":
            # a based literal's tick, an unbased `'0`/`'1`, or a cast — never
            # an operator; skip the tick alone so the digits after it are read
            # as text and never as an operand boundary.
            i += 1
            continue
        if d == 0:
            for t in order:
                if s.startswith(t, i):
                    # a UNARY operator has no operand on its left
                    j = i - 1
                    while j >= 0 and s[j].isspace():
                        j -= 1
                    if j < 0 or not (s[j].isalnum() or s[j] in "_)]}'"):
                        break
                    if t == '+' and s[j].isdigit() and s[j - 1:j].lower() == 'e':
                        break
                    return t
            for t in order:
                if s.startswith(t, i):
                    i += len(t) - 1
                    break
        i += 1
    return None


POWTOK = ('**',)
UARTOK = ('<<<', '>>>', '<<', '>>', '&&', '||', '&', '|', '+')
UARREAL = ('<<<', '>>>', '<<', '>>', '&', '|', '+')


def toppow100(init):
    return _toplevel(peel100(init), POWTOK) == '**'


def topuar100(init):
    """the TOP-LEVEL operator is one of the five UINT-minting arms.

    `&&` and `||` are in the token list ONLY so that they are recognised and
    stepped over rather than mistaken for `&` / `|` — they are not in the
    answer set, and the live control proves it.
    """
    return _toplevel(peel100(init), UARTOK) in UARREAL


def anyuar100(init):
    t = re.sub(r'&&|\|\||\*\*', ' ', init)
    return bool(re.search(r'<<<|>>>|<<|>>|&|\||\+', t))


def bare100(init):
    return bool(BARELIT.match(peel100(init).strip()))


def bname100(init):
    return bool(re.match(r'^[A-Za-z_]\w*(::[A-Za-z_]\w*)?$',
                         peel100(init).strip()))


def tags100(nm, ty, init):
    out = set()
    if toppow100(init):
        out.add('POW100')
    if '**' in init:
        out.add('POWW100')
    if topuar100(init):
        out.add('UAR100')
    if anyuar100(init):
        out.add('UARW100')
    if bare100(init):
        out.add('BARE100')
    elif bname100(init):
        out.add('BNAM100')
    return out


def digitsrc100(t):
    """the three ways the producer's leaf reading and slang's store part."""
    out = {}
    bd = S.bigdec96(t, 31)
    if bd:
        out['UDC100'] = len(bd)
    uo = Q.unbop97(t)
    if uo:
        out['UNBO100'] = len(uo)
    bw = Q.bwl97(t)
    if bw:
        out['BWL100'] = len(bw)
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
                for nm, ty, init in N.decls94(t):
                    tg = tags100(nm, ty, init)
                    if not tg:
                        hist['AGREE100'] = hist.get('AGREE100', 0) + 1
                        continue
                    for k in tg:
                        hist[k] = hist.get(k, 0) + 1
                    hits.setdefault(name, set()).add(
                        '%s: %s = %s' % ('+'.join(sorted(tg)), nm, init[:40]))
                for k, v in digitsrc100(t).items():
                    hist[k] = hist.get(k, 0) + v
                    hits.setdefault(name, set()).add('%s: %d' % (k, v))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must sight this pass's own arms, and it
    must LEAVE SOMETHING UNSIGHTED."""
    want = {'p1_powtop100': 'POW100', 'p2_uintdig100': 'UAR100',
            'p3_bare100': 'BARE100', 'p4_fence100': 'BNAM100',
            'y2_unsized96': 'UDC100', 'z1_unbased97': 'UNBO100',
            'z2_addmint97': 'UAR100'}
    d = os.path.join(HERE, 'grid')
    P = os.path.join(HERE, '..')
    files = [os.path.join(d, f) for f in sorted(os.listdir(d))
             if f.endswith('.sv')]
    for rel in ('r11u96repro/grid/y2_unsized96.sv',
                'r11u96repro/grid/y1_muldiv96.sv',
                'r11u97repro/grid/z1_unbased97.sv',
                'r11u97repro/grid/z2_addmint97.sv',
                'r11u97repro/grid/z3_cmpfam97.sv',
                'r11u94repro/grid/q4_negpkg94.sv',
                'r11u91repro/grid/p1_pkgin91.sv'):
        q = os.path.join(P, rel)
        if os.path.isfile(q):
            files.append(q)
    seen = {}
    for q in files:
        t = C.strip_noise(open(q, errors='replace').read())
        ks = set()
        for nm, ty, init in N.decls94(t):
            ks |= tags100(nm, ty, init)
        ks |= set(digitsrc100(t))
        ks.discard('UARW100')
        ks.discard('POWW100')
        seen[os.path.basename(q)[:-3]] = ks
    ok = True
    for a in sorted(want):
        got = seen.get(a, set())
        print('  %-18s %s' % (a, ' '.join(sorted(got)) or '-'))
        if a not in seen:
            print('  ARM %s not in the grid' % a)
            ok = False
        elif want[a] not in got:
            print('  ARM %s carries no %s — the scanner is blind'
                  % (a, want[a]))
            ok = False
    # THE LIVE NEGATIVE CONTROL.  `^`, `&&`, `||`, `!`, `?:`, `===`, `!==`, a
    # unary `+`, a comparison, a cast and a based literal must reach NOTHING
    # of this pass's three gate classes; `**` at the top, each of the five
    # UINT arms at the top, and a bare decimal must each reach exactly one.
    live = ("package z; localparam int A = 12 ^ 10; localparam int B = (1 && 1);\n"
            "  localparam int C = (0 || 1);  localparam int D = (!0);\n"
            "  localparam int E = (3 === 3); localparam int F = (3 !== 3);\n"
            "  localparam int G = (1 ? 2 : 3); localparam int H = (3 < 4);\n"
            "  localparam int I = int'(5);   localparam int J = 2 * 3;\n"
            "  localparam int K = 2 ** 3;    localparam int L = 1 + 2;\n"
            "  localparam int M = 12 & 10;   localparam int N = 12 | 3;\n"
            "  localparam int O = 1 << 3;    localparam int P = 32 >> 2;\n"
            "  localparam int Q = 1 <<< 3;   localparam int R = 32 >>> 2;\n"
            "  localparam int S = 2147483648; localparam int T = 8'hff;\n"
            "  localparam int U = (+5);      localparam int V = 8 - 1;\n"
            "  localparam int W = (2 ** 3) + 1; localparam int X = pk::YY;\n"
            "  localparam int Y = 4'b1010;   localparam int Z2 = -3; endpackage\n")
    lt = C.strip_noise(live)
    lk = {nm: tags100(nm, ty, init) for nm, ty, init in N.decls94(lt)}
    for nm, must in (('A', set()), ('B', set()), ('C', set()), ('D', set()),
                     ('E', set()), ('F', set()), ('G', set()), ('H', set()),
                     ('I', set()), ('J', set()), ('K', {'POW100', 'POWW100'}),
                     ('L', {'UAR100', 'UARW100'}),
                     ('M', {'UAR100', 'UARW100'}),
                     ('N', {'UAR100', 'UARW100'}),
                     ('O', {'UAR100', 'UARW100'}),
                     ('P', {'UAR100', 'UARW100'}),
                     ('Q', {'UAR100', 'UARW100'}),
                     ('R', {'UAR100', 'UARW100'}),
                     ('S', {'BARE100'}), ('T', set()),
                     # UARW100 is the LOOSE superset: a unary `+` is in it by
                     # design and UAR100 — the gate's class — is not.
                     ('U', {'UARW100'}), ('V', set()),
                     ('W', {'UAR100', 'UARW100', 'POWW100'}),
                     ('X', {'BNAM100'}), ('Y', set()), ('Z2', set())):
        got = lk.get(nm, set())
        print('  live %-3s %s' % (nm, ' '.join(sorted(got)) or '-'))
        if got != must:
            print('  live control %s: expected %s got %s'
                  % (nm, sorted(must) or '-', sorted(got) or '-'))
            ok = False
    # the three DIGIT SOURCES, each with its own live control
    for txt, must in (('localparam longint A = 2147483648;\n', {'UDC100': 1}),
                      ('localparam longint B = 1073741824;\n', {}),
                      ("wire x = '1 - 0;\n", {'UNBO100': 1}),
                      ("wire x = '0;\n", {}),
                      ("localparam int C = 4'd20;\n", {'BWL100': 1}),
                      ("localparam int D = 4'd12;\n", {})):
        got = digitsrc100(C.strip_noise(txt))
        print('  live digitsrc %-34s %s' % (txt.strip(), got or '-'))
        if got != must:
            print('  live digitsrc control failed: expected %s' % (must or '-'))
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
    roots = sys.argv[1:] or [os.path.expanduser(p) for p in
                             ('~/git-repos/uhdm2rtlil/test',
                              '~/git-repos/Surelog/tests',
                              '~/git-repos/Surelog/third_party/tests')]
    hits, hist = scan(roots)
    for k in sorted(hist):
        print('%-10s %d' % (k, hist[k]))
    print('--- candidate tests: %d' % len(hits))
    for t in sorted(hits):
        print('  %-44s %s' % (t, '; '.join(sorted(hits[t]))[:120]))
