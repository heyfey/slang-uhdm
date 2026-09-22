#!/usr/bin/env python3
"""r11u96 A-PRIORI MOVER CENSUS — three classes, one per law, each a STRICT
SUPERSET of the gate that lands, with a POSITIVE CONTROL that proves the
scanner can see and a LIVE NEGATIVE one that proves it can miss.

  MDM96  § pkgParamMulDivModIsIntReduce96 (LAW A) — a PACKAGE-homed parameter
         whose initializer's TOP-LEVEL operator is `*`, `/` or `%`.  That is
         the shape the new `red96IntMintTop96` flags answer.  Superset:
         nothing here checks that the parameter is READ through the
         package-parameter fold, that `red72Int64` succeeds, or the sign of
         the answer (a NEGATIVE answer already writes `INT:` through the
         landed `neg91` gate and does not move).
  MDMW96 ANY `*`, `/` or `%` anywhere in the initializer text — a superset of
         MDM96 in turn, so the hole between the written shape and the parsed
         one is a number and not a claim.
  UDC96  § unsizedDecLeafWrittenDigits96 (LAW B) — an UNSIZED DECIMAL literal
         whose magnitude is at least 2**31 ANYWHERE in the file.  This class
         is deliberately not parameter-keyed: LAW B changes `red72Int64`,
         which is read from ParamEmit, ModuleEmit and ExprEmit alike, so the
         superset is "does this file even contain a literal the two readings
         disagree on".  Below 2**31 the written digits and slang's `int`-typed
         store are the same number and no cell can move.
  UDC96W the same literals from 2**30 — the calibration band that must be
         SIGHTED and must NOT move, so that "0 movers" is a measurement.
  K1C96  § kind1ConcatKeepsNoTs96 (LAW C) — a PACKAGE-homed parameter with a
         WRITTEN data type (`red91PkgDeclKind91` kind 1) whose initializer
         contains a `{...}` concatenation or replication.  Superset: nothing
         checks that the parameter is read through a module-homed hop with a
         declared type, that the read is written `pkg::NAME`, or that it
         reaches a `'{...}` pattern where the probe can see it.

All three are FILE-keyed (a declaration, not a span population): these laws
fire wherever the parameter is READ.

usage:  census96.py [<corpus dir> ...]      (default: the pinned corpora)
        census96.py --selftest              (the controls)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
for sib in ('r11u94repro', 'r11u87repro'):
    for cand in (os.path.join(HERE, '..', sib),
                 os.path.expanduser(
                     '~/git-repos/slang-uhdm/tools/probe/' + sib)):
        if os.path.isdir(cand):
            sys.path.insert(0, cand)
            break
import census94 as N                                           # noqa: E402
C = N.C

# An unsized decimal literal: digits not preceded by a base tick and not part
# of an identifier.  `\b(?<![\w'])` keeps `8'd5`, `x1`, `1e5` and `1.5` out.
UDEC = re.compile(r"(?<![\w'.$])(\d[\d_]*)(?![\w'.])")


def topop96(init):
    """the initializer's TOP-LEVEL operator is `*`, `/` or `%`.

    `**` is NOT this class: `vpiPowerOp` is its own arm and its own pass.
    A `//` or `/*` cannot appear — `strip_noise` has removed the comments.
    """
    s = init.strip()
    d = 0
    for i, ch in enumerate(s):
        if ch in '([{':
            d += 1
        elif ch in ')]}':
            d -= 1
        elif d == 0 and ch in '*/%':
            if ch == '*' and (s[i - 1:i] == '*' or s[i + 1:i + 2] == '*'):
                continue
            j = i - 1
            while j >= 0 and s[j].isspace():
                j -= 1
            if j >= 0 and (s[j].isalnum() or s[j] in "_)]}'"):
                return True
    return False


def anyop96(init):
    s = re.sub(r'\*\*', ' ', init)
    return any(ch in s for ch in '*/%')


def bigdec96(text, bits):
    """every unsized decimal literal in `text` worth at least 2**bits"""
    out = []
    lim = 1 << bits
    for m in UDEC.finditer(text):
        raw = m.group(1).replace('_', '')
        if len(raw) > 30:
            out.append(raw)
            continue
        try:
            v = int(raw)
        except ValueError:
            continue
        if v >= lim:
            out.append(raw)
    return out


def hascat96(init):
    """a `{...}` that is a concatenation or a replication, not a `'{...}`
    assignment pattern (which is a different producer road entirely)."""
    for i, ch in enumerate(init):
        if ch == '{' and init[i - 1:i] != "'":
            return True
    return False


def tags96(nm, ty, init):
    out = set()
    sg, dm = N.syn94(ty)
    kind1 = not (sg or dm) and bool(
        [w for w in N.WORD.findall(re.sub(r'\[[^\]]*\]', ' ', ty))
         if w not in N.NOTTY])
    if topop96(init):
        out.add('MDM96')
    if anyop96(init):
        out.add('MDMW96')
    if kind1 and hascat96(init):
        out.add('K1C96')
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
                    tg = tags96(nm, ty, init)
                    if not tg:
                        hist['AGREE96'] = hist.get('AGREE96', 0) + 1
                        continue
                    for k in tg:
                        hist[k] = hist.get(k, 0) + 1
                    hits.setdefault(name, set()).add(
                        '%s: %s = %s' % ('+'.join(sorted(tg)), nm, init[:40]))
                big = bigdec96(t, 31)
                if big:
                    hist['UDC96'] = hist.get('UDC96', 0) + len(big)
                    hits.setdefault(name, set()).add(
                        'UDC96: %s' % ' '.join(sorted(set(big))[:6]))
                mid = [v for v in bigdec96(t, 30) if v not in big]
                if mid:
                    hist['UDC96W'] = hist.get('UDC96W', 0) + len(mid)
                    hits.setdefault(name, set()).add(
                        'UDC96W: %s' % ' '.join(sorted(set(mid))[:6]))
    return hits, hist


def selftest():
    """POSITIVE CONTROL — the scanner must sight this pass's own arms, and
    must LEAVE SOMETHING UNSIGHTED."""
    want = {'y1_muldiv96': 'MDM96', 'y2_unsized96': 'UDC96',
            'y3_kind1cat96': 'K1C96', 'y4_bail96': 'UDC96',
            'x2_minusedge94v': 'MDM96', 'x6_concatvote94v': 'K1C96'}
    d = os.path.join(HERE, 'grid')
    P = os.path.join(HERE, '..')
    files = [os.path.join(d, f) for f in sorted(os.listdir(d))
             if f.endswith('.sv')]
    for rel in ('r11v94repro/grid/x2_minusedge94v.sv',
                'r11v94repro/grid/x6_concatvote94v.sv',
                'r11u94repro/grid/q4_negpkg94.sv',
                'r11u91repro/grid/p1_pkgin91.sv',
                'r11u87repro/grid/y1_sgnd87.sv'):
        q = os.path.join(P, rel)
        if os.path.isfile(q):
            files.append(q)
    seen = {}
    for q in files:
        t = C.strip_noise(open(q, errors='replace').read())
        ks = set()
        for nm, ty, init in N.decls94(t):
            ks |= tags96(nm, ty, init)
        if bigdec96(t, 31):
            ks.add('UDC96')
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
    # THE LIVE NEGATIVE CONTROL.  `**`, `+`, a shift and a bare `-` must not
    # reach MDM96; a kind-2 (implicit + signing) concat must not reach K1C96
    # (it is r11v94's landed ground, not this pass's); a `'{...}` pattern is
    # not a concatenation; and a decimal below 2**31 must not reach UDC96.
    live = ("package z; localparam int A = 2 ** 3; localparam int B = 1 + 2;\n"
            "  localparam int C = 1 << 3; localparam int D = 8 - 1;\n"
            "  localparam int E = 2 * 3; localparam int F = 6 / 2;\n"
            "  localparam int G = 7 % 4; localparam signed H = {4'd1,4'd2};\n"
            "  localparam int I = {4'd1,4'd2}; localparam int J = 2147483647;\n"
            "  localparam int K = 2147483648; localparam t L = '{a:1};\n"
            "  localparam int M = int'(2 * 3); endpackage\n")
    lt = C.strip_noise(live)
    lk = {nm: tags96(nm, ty, init) for nm, ty, init in N.decls94(lt)}
    for nm, must in (('A', set()), ('B', set()), ('C', set()), ('D', set()),
                     ('E', {'MDM96', 'MDMW96'}), ('F', {'MDM96', 'MDMW96'}),
                     ('G', {'MDM96', 'MDMW96'}), ('H', set()),
                     ('I', {'K1C96'}), ('J', set()), ('K', set()),
                     ('L', set())):
        got = lk.get(nm, set())
        print('  live %-3s %s' % (nm, ' '.join(sorted(got)) or '-'))
        if got != must:
            print('  live control %s: expected %s' % (nm, sorted(must) or '-'))
            ok = False
    lb = bigdec96(lt, 31)
    print('  live UDC96 literals: %s' % (' '.join(lb) or '-'))
    if lb != ['2147483648']:
        print('  live UDC96: expected exactly 2147483648')
        ok = False
    if 'M' in lk and lk['M']:
        # an explicit cast still WRAPS a `*`; MDM96 is a superset and is
        # ALLOWED to sight it — the gate declines it because `stripImplicitConv`
        # does not peel an explicit cast.  Reported, not scored.
        print('  live M (explicit cast over `*`) sighted by the SUPERSET: %s'
              % ' '.join(sorted(lk['M'])))
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
    # `UHDM2RTLIL_TESTS = ~/git-repos/uhdm2rtlil/test`, SINGULAR (r11u94's R5).
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
