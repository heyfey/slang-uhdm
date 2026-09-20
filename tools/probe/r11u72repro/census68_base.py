#!/usr/bin/env python3
"""r11u66 A-PRIORI MOVER CENSUS — which corpus tests can reach the ELABORATED
pattern-operand fold with a setter whose reduce-table answer is `vpiIntConst`.

It is a SUPERSET BY CONSTRUCTION: it reads SOURCES only, and it never asks
whether the pattern's parameter is struct-typed, whether the elaborated copy
flat-folds at all, or whether the setter survives the admission fences.  So the
measured movers must be a SUBSET of what it prints.

The classification mirrors the mint's own branch order at the site:

  BASED   a based literal (`32'h28`, `4'b1010`)      -> the IntegerLiteral arm
  PLAIN   an unsized decimal (`7`)                   -> the IntegerLiteral arm
  NAME    a bare identifier                          -> RULE 2 / the enum arm
  AGG     anything holding `{`                       -> the concat/replication arms
  CAST    a `'(` cast                                -> the Conversion arm
  INTISH  a top-level `-`, `*`, `/`, `%`, `**`, or a `+`/`-` over a name whose
          own initializer is INTISH (to a fixpoint)  -> **THE LAW CAN FIRE**
  UINTISH a shift / bitwise / compare / ternary / `$` call and nothing else
                                                     -> the table answers UINT
                                                        or abstains: a no-op

usage:  census66.py [<corpus dir> ...]      (default: both pinned corpora)
        census66.py --selftest              (the positive control on the grid)
"""
import os, re, sys

HOME = os.path.expanduser('~')
DEFAULT = [os.path.join(HOME, 'git-repos', 'Surelog', 'tests'),
           os.path.join(HOME, 'git-repos', 'Surelog', 'third_party', 'tests'),
           os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test')]
EXTS = ('.sv', '.svh', '.v', '.vh')

BASED = re.compile(r"^\d*'[sS]?[hHbBoOdDxXzZ][0-9a-fA-FxXzZ?_]+$")
PLAIN = re.compile(r'^[0-9_]+$')
NAME = re.compile(r'^[A-Za-z_][A-Za-z_0-9]*(\s*::\s*[A-Za-z_][A-Za-z_0-9]*)*$')
INTOP = re.compile(r'(\*\*|[-*/%])')
IDENT = re.compile(r'[A-Za-z_][A-Za-z_0-9]*')


def strip_noise(t):
    t = re.sub(r'//[^\n]*', '', t)
    t = re.sub(r'/\*.*?\*/', '', t, flags=re.S)
    t = re.sub(r'"(\\.|[^"\\])*"', '""', t)
    return t


def spans(t):
    """every `'{ ... }` span, with the 200 characters before it (for the
    parameter/localparam test)"""
    out = []
    i = 0
    while True:
        j = t.find("'{", i)
        if j < 0:
            break
        d = 0
        k = j + 1
        while k < len(t):
            if t[k] == '{':
                d += 1
            elif t[k] == '}':
                d -= 1
                if d == 0:
                    break
            k += 1
        if k >= len(t):
            break
        out.append((t[max(0, j - 400):j], t[j + 2:k]))
        i = k + 1
    return out


def split_top(body):
    out, d, cur = [], 0, ''
    for ch in body:
        if ch in '({[':
            d += 1
        elif ch in ')}]':
            d -= 1
        if ch == ',' and d == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    out.append(cur)
    return [x for x in (y.strip() for y in out) if x]


def setter_of(el):
    d = 0
    for i, ch in enumerate(el):
        if ch in '({[':
            d += 1
        elif ch in ')}]':
            d -= 1
        elif ch == ':' and d == 0 and not el[i:i + 2] == '::':
            if i and el[i - 1] == ':':
                continue
            return el[i + 1:].strip()
    return el.strip()


def toplevel_ops(x):
    """every operator token at bracket depth 0, with based-literal base letters
    masked so `32'd40` does not read as a `d` operator"""
    y = re.sub(r"\d*'[sS]?[hHbBoOdDxXzZ][0-9a-fA-FxXzZ?_]+", ' NUM ', x)
    out, d = [], 0
    i = 0
    while i < len(y):
        ch = y[i]
        if ch in '({[':
            d += 1
        elif ch in ')}]':
            d -= 1
        elif d == 0:
            for tok in ('>>>', '<<<', '**', '<<', '>>', '==', '!=', '<=', '>=',
                        '&&', '||', '?', '+', '-', '*', '/', '%', '&', '|',
                        '^', '<', '>'):
                if y.startswith(tok, i):
                    out.append(tok)
                    i += len(tok) - 1
                    break
        i += 1
    return out


def operands_of(x, ops):
    """the bracket-depth-0 operand texts, split on every top-level operator"""
    y = re.sub(r"(\d*'[sS]?[hHbBoOdDxXzZ][0-9a-fA-FxXzZ?_]+)",
               lambda m: 'N' * len(m.group(1)), x)
    parts, cur, d, i = [], '', 0, 0
    while i < len(x):
        ch = y[i]
        if ch in '({[':
            d += 1
        elif ch in ')}]':
            d -= 1
        hit = None
        if d == 0:
            for tok in ('>>>', '<<<', '**', '<<', '>>', '==', '!=', '<=', '>=',
                        '&&', '||', '?', ':', '+', '-', '*', '/', '%', '&',
                        '|', '^', '<', '>'):
                if y.startswith(tok, i):
                    hit = tok
                    break
        if hit:
            parts.append(cur)
            cur = ''
            i += len(hit)
            continue
        cur += x[i]
        i += 1
    parts.append(cur)
    return [q.strip() for q in parts if q.strip()]


def signedish(x, inits, depth=0):
    """the four reduced constant types that make an enclosing `+` take the
    SIGNED arm: vpiInt / String / Real / Dec — here, an INT-arm expression, a
    based-DECIMAL literal, or a NAME whose initializer is either"""
    if depth > 8:
        return False
    x = x.strip()
    while x.startswith('(') and x.endswith(')'):
        x = x[1:-1].strip()
    if re.match(r"^\d*'[sS]?[dD][0-9_]+$", x):
        return True
    c = classify(x, inits, depth + 1)
    if c == 'INTISH':
        return True
    if NAME.match(x):
        nm = x.replace(' ', '')
        return nm in inits and signedish(inits[nm], inits, depth + 1)
    return False


def classify(x, inits, depth=0):
    x = x.strip()
    while x.startswith('(') and x.endswith(')'):
        x = x[1:-1].strip()
    if not x or depth > 8:
        return 'OTHER'
    ops = toplevel_ops(x)
    if not ops:
        if BASED.match(x):
            return 'BASED'
        if PLAIN.match(x):
            return 'PLAIN'
        if NAME.match(x):
            nm = x.replace(' ', '')
            if nm in inits and classify(inits[nm], inits, depth + 1) == 'INTISH':
                return 'INTISH'
            return 'NAME'
        if '{' in x:
            return 'AGG'
        if "'(" in x:
            return 'CAST'
        if x.startswith('$'):
            return 'UINTISH'
        return 'OTHER'
    # a UNARY minus with nothing else at the top is the vpiMinusOp arm
    if ops == ['-'] and x.lstrip().startswith('-'):
        return 'INTISH'
    if '?' in ops:
        return 'UINTISH'
    for o in ('==', '!=', '<=', '>=', '<', '>', '&&', '||', '&', '|', '^',
              '<<', '>>', '>>>', '<<<'):
        if o in ops:
            return 'UINTISH'
    if '-' in ops:
        return 'INTISH'
    if '+' in ops:
        for o in operands_of(x, ops):
            if signedish(o, inits, depth + 1):
                return 'INTISH'
        return 'UINTISH'
    for o in ('**', '*', '/', '%'):
        if o in ops:
            return 'INTISH'
    return 'UINTISH'


def param_inits(t):
    """NAME -> initializer text, for every parameter/localparam assignment"""
    out = {}
    for m in re.finditer(r'\b(?:parameter|localparam)\b([^;]*);', t, re.S):
        for part in split_top(m.group(1)):
            mm = re.match(r'^(.*?)\b([A-Za-z_]\w*)\s*=\s*(.+)$', part, re.S)
            if mm and "'{" not in mm.group(3):
                out[mm.group(2)] = mm.group(3).strip()
    return out


def walk(roots, loose=False):
    hits = {}
    hist = {}
    for root in roots:
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn if d not in ('.git', 'slpp_all', 'slpp_unit')]
            for f in fn:
                if not f.endswith(EXTS):
                    continue
                p = os.path.join(dp, f)
                try:
                    t = strip_noise(open(p, errors='replace').read())
                except OSError:
                    continue
                if "'{" not in t:
                    continue
                inits = param_inits(t)
                for pre, body in spans(t):
                    if not loose and not re.search(
                            r'\b(parameter|localparam)\b', pre):
                        continue
                    for el in split_top(body):
                        c = classify(setter_of(el), inits)
                        hist[c] = hist.get(c, 0) + 1
                        if c == 'INTISH':
                            hits.setdefault(testname(root, p), set()).add(
                                setter_of(el)[:60])
    return hits, hist


def testname(root, p):
    rel = os.path.relpath(p, root)
    return rel.split(os.sep)[0]


def selftest():
    here = os.path.dirname(os.path.abspath(__file__))
    grid = os.path.join(here, 'grid')
    if not os.path.isdir(grid):
        grid = here
    want = {'g3_neg66', 'g4_base66', 'g5_width66', 'g6_hold66', 'g7_add66',
            'x1_optable', 'v9', 'g8_face66'}
    seen = {}
    for f in sorted(os.listdir(grid)):
        if not f.endswith('.sv'):
            continue
        t = strip_noise(open(os.path.join(grid, f), errors='replace').read())
        inits = param_inits(t)
        cls = set()
        for pre, body in spans(t):
            if not re.search(r'\b(parameter|localparam)\b', pre):
                continue
            for el in split_top(body):
                cls.add(classify(setter_of(el), inits))
        seen[f[:-3]] = cls
        print('  %-16s %s' % (f[:-3], ' '.join(sorted(cls))))
    ok = True
    for a in sorted(want):
        if a not in seen:
            print('  MISSING ARM %s' % a)
            ok = False
        elif 'INTISH' not in seen[a]:
            print('  ARM %s carries NO INTISH setter — the scanner is blind' % a)
            ok = False
    # THE NEGATIVE HALF of the control — the setters the law must NOT claim,
    # each one a cell measured on a real v1.87 golden in this pass's grid.
    inits = {'LM': 'N * 2', 'LA': 'N + 1', 'LH': "32'h28", 'LD': "32'd40",
             'N': '8', 'K': '6', 'KU': '6'}
    cases = [('K * 2', 'INTISH'), ('K / 2', 'INTISH'), ('K % 4', 'INTISH'),
             ('K ** 2', 'INTISH'), ('2 - 5', 'INTISH'), ('-K', 'INTISH'),
             ("-16'd5", 'INTISH'), ('LM + 1', 'INTISH'), ('LD + 1', 'INTISH'),
             ('(N - 1) + 0', 'INTISH'),
             ('KU >> 1', 'UINTISH'), ('KU >>> 1', 'UINTISH'),
             ('KU & 3', 'UINTISH'), ('KU | 8', 'UINTISH'),
             ('KU << 1', 'UINTISH'), ('KU ^ 3', 'UINTISH'),
             ('K > 2', 'UINTISH'), ('K ? 3 : 4', 'UINTISH'),
             ('$clog2(40)', 'UINTISH'), ('$bits(K)', 'UINTISH'),
             ('LA + 1', 'UINTISH'), ('LH + 1', 'UINTISH'),
             ('(N - 1) << 1', 'UINTISH'),
             ("32'd40", 'BASED'), ("32'h28", 'BASED'), ("4'b1111", 'BASED'),
             ('7', 'PLAIN'), ('K', 'NAME'), ("int'(K)", 'CAST'),
             ("{4'b1010, 4'b0101}", 'AGG'), ("{3{4'b1010}}", 'AGG')]
    for txt, want_c in cases:
        got = classify(txt, inits)
        flag = 'ok ' if got == want_c else 'BAD'
        if got != want_c:
            ok = False
        print('  %s %-22s want=%-8s got=%s' % (flag, txt, want_c, got))
    print('SELFTEST %s' % ('PASS' if ok else 'FAIL'))
    return 0 if ok else 1


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--selftest':
        sys.exit(selftest())
    loose = '--loose' in sys.argv
    roots = [a for a in sys.argv[1:] if not a.startswith('--')] or DEFAULT
    hits, hist = walk(roots, loose)
    for k in sorted(hits):
        print('CANDIDATE %-42s %s' % (k, ' | '.join(sorted(hits[k]))[:110]))
    print('SETTERS %s' % ' '.join('%s=%d' % kv for kv in sorted(hist.items())))
    print('CANDIDATES %d' % len(hits))
