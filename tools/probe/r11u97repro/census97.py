#!/usr/bin/env python3
"""r11u97 A-PRIORI MOVER CENSUS — three classes, one per law, each a STRICT
SUPERSET of the gate that lands, with a POSITIVE CONTROL that proves the
scanner can see and a LIVE NEGATIVE one that proves it can miss.

  UNB97  § unbasedUnsizedIsOneDigit97 (LAW A) — a PACKAGE-homed parameter
         whose initializer contains an UNBASED-UNSIZED literal `'0` or `'1`.
         Superset: nothing here checks the top operator, that the parameter is
         READ through the package-parameter fold, or that `red72Int64`
         succeeds.  `'x` and `'z` are NOT in the class — the arm declines an
         unknown bit and golden leaves those shapes unfolded.
  UNBF97 ANY `'0` / `'1` token ANYWHERE in the file.  LAW A changes
         `red72Int64`, which ParamEmit, ModuleEmit and ExprEmit all read, so
         this file-keyed superset is the honest one: "does this file contain a
         literal the two readings disagree on at all".
  ADD97  § addMintFollowsOperandMint97 (LAW B) — a PACKAGE-homed parameter
         whose initializer's TOP-LEVEL operator is `+`.  Superset: nothing
         checks whether either operand mints `INT:`, which is the gate that
         lands.
  ADDW97 ANY `+` anywhere in the initializer — a superset of ADD97 in turn, so
         the hole between the written shape and the parsed one is a number.
  CMP97  § intCompareIsMinusOne97 (LAW C) — a PACKAGE-homed parameter whose
         initializer's TOP-LEVEL operator is one of `<`, `>`, `<=`, `>=`,
         `==`, `!=`.  Superset: nothing checks the declared type, the truth of
         the comparison, or that both operands reduce.
  CMPF97 ANY of those six operators ANYWHERE in the file — LAW C also adds an
         arm to the SHARED `red72Int64`, so the same file-keyed superset
         applies to it as to LAW A.

`===` / `!==` / `&&` / `||` / `!` are DELIBERATELY out of every class: they are
not on `reduceCompOp`'s road, every one of their measured cells is EQUAL on
both binaries, and the live negative control below proves the scanner leaves
them alone.

usage:  census97.py [<corpus dir> ...]      (default: the pinned corpora)
        census97.py --selftest              (the controls)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
for sib in ('r11u96repro', 'r11u94repro', 'r11u87repro'):
    for cand in (os.path.join(HERE, '..', sib),
                 os.path.expanduser(
                     '~/git-repos/slang-uhdm/tools/probe/' + sib)):
        if os.path.isdir(cand):
            sys.path.insert(0, cand)
            break
import census96 as S                                           # noqa: E402

N = S.N
C = S.C

# An unbased-unsized literal: a tick followed by 0 or 1 and NOT by a base
# letter, and not preceded by a digit (which would make it a based literal's
# tick) or by a word character (a cast's `'`).
UNB = re.compile(r"(?<![\w\]\)])'([01])(?![\w'])")
# The six comparison operators, written so that `<=` beats `<`, `!==` and
# `===` are excluded, and `<<`/`>>`/`=>`/`<->` never match.
CMPOPS = ('==', '!=', '<=', '>=', '<', '>')


def hasunb97(text):
    return [m.group(1) for m in UNB.finditer(text)]


# The OPERAND face of the same literal.  `red72Int64`'s arm is confined to
# `inArm` — the literal only reads as a digit when it is an OPERAND of an
# operation — so a `'0`/`'1` written as a bare assignment or connection
# (`q <= '0;`, `.rst('1)`), which is the overwhelming majority of the corpus's
# 28 000 of them, can move NOTHING.  This class keeps the ones whose nearest
# non-space neighbour on either side is an arithmetic, shift or comparison
# operator.  It is still a SUPERSET: it does not ask whether the expression
# reaches `red72Int64` at all.
OPCH = set('+-*/%<>')


def unbop97(text):
    out = []
    for m in UNB.finditer(text):
        a, b = m.start(), m.end()
        j = b
        while j < len(text) and text[j] in ' \t\n)':
            j += 1
        k = a - 1
        while k >= 0 and text[k] in ' \t\n(':
            k -= 1
        if (j < len(text) and text[j] in OPCH) or (k >= 0 and text[k] in OPCH):
            out.append(m.group(1))
    return out


BASEDL = re.compile(r"(\d[\d_]*)'\s*([sS]?)\s*([dDhHbBoO])([0-9a-fA-FxXzZ?_]+)")


def bwl97(text):
    """a BASED literal whose WRITTEN DIGITS do not fit its own width.

    r11u76's `red76BasedLeafDigits` reads such a leaf as its digits where
    slang's store has already truncated it, so a NAME over one is a second
    place where the store and our reduce disagree and the widened chain guard
    can newly fold.  `4'd12` fits and is NOT in the class; `4'd20` is.
    """
    out = []
    for m in BASEDL.finditer(text):
        try:
            w = int(m.group(1).replace('_', ''))
        except ValueError:
            continue
        base = {'d': 10, 'h': 16, 'b': 2, 'o': 8}[m.group(3).lower()]
        dg = m.group(4).replace('_', '')
        if not dg or any(c in 'xXzZ?' for c in dg):
            continue
        try:
            v = int(dg, base)
        except ValueError:
            continue
        if w <= 0 or w > 64:
            continue
        if v >= (1 << w):
            out.append(m.group(0))
    return out


def _split_top(s):
    """the top-level comparison operator of `s`, or None.

    Depth-aware over `()`, `[]`, `{}`; `===`, `!==`, `<<`, `>>`, `<<<`, `>>>`,
    `->`, `<->`, `=>`, `<=` in a NON-comparison sense (there is none inside an
    initializer) and `?:` are all excluded by the token reads below.
    """
    d = 0
    i = 0
    n = len(s)
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
        if ch in '"':
            i += 1
            while i < n and s[i] != '"':
                i += 2 if s[i] == '\\' else 1
            i += 1
            continue
        if d == 0:
            three = s[i:i + 3]
            two = s[i:i + 2]
            if three in ('===', '!==', '<<<', '>>>'):
                i += 3
                continue
            if two in ('<<', '>>', '->', '=>', '&&', '||', '**'):
                i += 2
                continue
            if two in ('==', '!=', '<=', '>='):
                return two
            if ch in '<>':
                return ch
        i += 1
    return None


def peel97(init):
    """peel BALANCED outer parentheses.

    slang does not build a node for a parenthesized expression — `(3 < 4)`
    binds straight to the `BinaryExpression` and only its `syntax` pointer
    remembers the parentheses — so the gate that lands sees the comparison at
    the top of `localparam int CLT = (3 < 4);`.  A census that read the
    written text literally would be BLIND to the commonest written form.
    """
    s = init.strip()
    while len(s) >= 2 and s[0] == '(' and s[-1] == ')':
        d = 0
        ok = True
        for i, ch in enumerate(s):
            if ch == '(':
                d += 1
            elif ch == ')':
                d -= 1
                if d == 0 and i != len(s) - 1:
                    ok = False
                    break
        if not ok:
            break
        s = s[1:-1].strip()
    return s


def topcmp97(init):
    return _split_top(peel97(init)) is not None


def anycmp97(text):
    """any of the six operators anywhere, `===`/`!==`/shifts excluded."""
    t = re.sub(r'===|!==|<<<|>>>|<<|>>|->|=>|&&|\|\|', ' ', text)
    return bool(re.search(r'==|!=|<=|>=|<|>', t))


def topadd97(init):
    """the initializer's TOP-LEVEL operator is a BINARY `+`."""
    s = peel97(init)
    d = 0
    for i, ch in enumerate(s):
        if ch in '([{':
            d += 1
        elif ch in ')]}':
            d -= 1
        elif d == 0 and ch == '+':
            if s[i - 1:i] == '+' or s[i + 1:i + 2] == '+':
                continue
            j = i - 1
            while j >= 0 and s[j].isspace():
                j -= 1
            # a binary `+` has an operand on its left; a unary one does not,
            # and `1e+5` / `'+` are not operators at all.
            if j >= 0 and (s[j].isalnum() or s[j] in "_)]}'"):
                if s[j].isdigit() and s[j - 1:j].lower() == 'e':
                    continue
                return True
    return False


def tags97(nm, ty, init):
    out = set()
    if hasunb97(init):
        out.add('UNB97')
    if topadd97(init):
        out.add('ADD97')
    if '+' in init:
        out.add('ADDW97')
    if topcmp97(init):
        out.add('CMP97')
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
                    tg = tags97(nm, ty, init)
                    if not tg:
                        hist['AGREE97'] = hist.get('AGREE97', 0) + 1
                        continue
                    for k in tg:
                        hist[k] = hist.get(k, 0) + 1
                    hits.setdefault(name, set()).add(
                        '%s: %s = %s' % ('+'.join(sorted(tg)), nm, init[:40]))
                ub = hasunb97(t)
                if ub:
                    hist['UNBF97'] = hist.get('UNBF97', 0) + len(ub)
                uo = unbop97(t)
                if uo:
                    hist['UNBO97'] = hist.get('UNBO97', 0) + len(uo)
                    hits.setdefault(name, set()).add('UNBO97: %d' % len(uo))
                # § chainStoreChecksTheInitializer97 — the widened NAME guard
                # can only change a cell where the store and our reduce
                # disagree, which is the three DIGIT arms and nothing else.
                bd = S.bigdec96(t, 31)
                if bd:
                    hist['UDC97'] = hist.get('UDC97', 0) + len(bd)
                    hits.setdefault(name, set()).add('UDC97: %d' % len(bd))
                bw = bwl97(t)
                if bw:
                    hist['BWL97'] = hist.get('BWL97', 0) + len(bw)
                    hits.setdefault(name, set()).add('BWL97: %d' % len(bw))
                if anycmp97(t):
                    hist['CMPF97'] = hist.get('CMPF97', 0) + 1
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must sight this pass's own arms, and
    must LEAVE SOMETHING UNSIGHTED."""
    want = {'z1_unbased97': 'UNB97', 'z2_addmint97': 'ADD97',
            'z3_cmpfam97': 'CMP97', 'z5_chain97': 'UDC97',
            'v1_amulbrk96v': 'UNB97', 'v5_unbased96v': 'UNBO97',
            'y2_unsized96': 'UDC97'}
    d = os.path.join(HERE, 'grid')
    P = os.path.join(HERE, '..')
    files = [os.path.join(d, f) for f in sorted(os.listdir(d))
             if f.endswith('.sv')]
    for rel in ('r11u96repro/grid/y2_unsized96.sv',
                'r11v96repro/grid/v1_amulbrk96v.sv',
                'r11v96repro/grid/v5_unbased96v.sv',
                'r11u96repro/grid/y1_muldiv96.sv',
                'r11u96repro/grid/y3_kind1cat96.sv',
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
            ks |= tags97(nm, ty, init)
        if unbop97(t):
            ks.add('UNBO97')
        if S.bigdec96(t, 31):
            ks.add('UDC97')
        if bwl97(t):
            ks.add('BWL97')
        ks.discard('ADDW97')
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
    # THE LIVE NEGATIVE CONTROL.  `'x`/`'z`, `**`, `<<`, `&&`, `||`, `===`,
    # `!==`, a unary `+`, a cast tick and a based literal's tick must reach
    # NOTHING; `'1`, a top-level `+` and each of the six comparisons must.
    live = ("package z; localparam int A = 'x - 0; localparam int B = 'z * 2;\n"
            "  localparam int C = 2 ** 3;  localparam int D = 1 << 3;\n"
            "  localparam int E = (1 && 1); localparam int F = (0 || 1);\n"
            "  localparam int G = (3 === 3); localparam int H = (3 !== 3);\n"
            "  localparam int I = 8'd10;    localparam int J = 2 * 3;\n"
            "  localparam int K = '1 - 0;   localparam int L = 2 * 3 + 1;\n"
            "  localparam int M = (3 < 4);  localparam int N = (3 >= 4);\n"
            "  localparam int O = (3 == 4); localparam int P = (3 != 4);\n"
            "  localparam int Q = (3 <= 4); localparam int R = (3 > 4);\n"
            "  localparam int S = int'(5);  localparam int T = 8 - 1;\n"
            "  localparam int U = (1 ? 2 : 3); endpackage\n")
    lt = C.strip_noise(live)
    lk = {nm: tags97(nm, ty, init) for nm, ty, init in N.decls94(lt)}
    for nm, must in (('A', set()), ('B', set()), ('C', set()), ('D', set()),
                     ('E', set()), ('F', set()), ('G', set()), ('H', set()),
                     ('I', set()), ('J', set()), ('K', {'UNB97'}),
                     ('L', {'ADD97', 'ADDW97'}), ('M', {'CMP97'}),
                     ('N', {'CMP97'}), ('O', {'CMP97'}), ('P', {'CMP97'}),
                     ('Q', {'CMP97'}), ('R', {'CMP97'}), ('S', set()),
                     ('T', set()), ('U', set())):
        got = lk.get(nm, set())
        print('  live %-3s %s' % (nm, ' '.join(sorted(got)) or '-'))
        if got != must:
            print('  live control %s: expected %s got %s'
                  % (nm, sorted(must) or '-', sorted(got) or '-'))
            ok = False
    lb = hasunb97(lt)
    print('  live UNB97 literals: %s' % (' '.join(lb) or '-'))
    if lb != ['1']:
        print("  live UNB97: expected exactly one `'1`")
        ok = False
    # the OPERAND face: `'1 - 0` is an operand, a bare `q = '0` is not.
    for txt, must in (("wire x = '0;\n", []), ("wire x = '1 - 0;\n", ['1']),
                      ("wire x = 2 * '1;\n", ['1']),
                      ("m u (.a('0), .b('1));\n", []),
                      ("wire y = ('1);\n", [])):
        got = unbop97(C.strip_noise(txt))
        print('  live UNBO97 %-24s %s' % (txt.strip(), got or '-'))
        if got != must:
            print('  live UNBO97 control failed: expected %s' % (must or '-'))
            ok = False
    for txt, must in (("localparam int A = 4'd12;\n", []),
                      ("localparam int B = 4'd20;\n", ["4'd20"]),
                      ("localparam int C = 8'hff;\n", []),
                      ("localparam int D = 4'hff;\n", ["4'hff"]),
                      ("localparam int E = 2'b11;\n", []),
                      ("localparam int F = 2'b111;\n", ["2'b111"])):
        got = bwl97(C.strip_noise(txt))
        print('  live BWL97 %-30s %s' % (txt.strip(), got or '-'))
        if got != must:
            print('  live BWL97 control failed: expected %s' % (must or '-'))
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
    # THE ROOTS ARE THE SWEEP'S OWN — `verify_golden.py:50` reads
    # `UHDM2RTLIL_TESTS = ~/git-repos/uhdm2rtlil/test`, SINGULAR.
    roots = sys.argv[1:] or [
        os.path.expanduser('~/git-repos/uhdm2rtlil/test'),
        os.path.expanduser('~/git-repos/Surelog/tests'),
        os.path.expanduser('~/git-repos/Surelog/third_party/tests'),
    ]
    hits, hist = scan(roots)
    for k in sorted(hist):
        print('%-10s %d' % (k, hist[k]))
    print('--- candidate tests: %d' % len(hits))
