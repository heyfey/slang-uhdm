#!/usr/bin/env python3
# r11u54 A-PRIORI MOVER PREDICTION, BY NAME — the TIGHT list.
#
# `cen54.py` is the superset (any package parameter whose Rhs carries a brace).
# This one models the two landed gates directly, so the sweep's byte movers can
# be checked against a list written BEFORE the sweep:
#
#   ROAD B (§ pkgElabConcatTreeNoFold54): a PACKAGE parameter whose Rhs
#     contains a concatenation `{...}` or replication `{N{...}}` REACHABLE
#     through binary/unary operators and casts only (a conditional stops the
#     walk, an assignment pattern `'{` is a different family) AND at least one
#     of its leaves is a NAME (a pure-literal concat is already equal).
#
#   ROAD D (§ pkgPatEvalFuncElemWidth54): a PACKAGE parameter whose Rhs is an
#     assignment pattern `'{...}` AND whose NAME appears as a call ARGUMENT
#     inside a PARAMETER DECLARATION anywhere in the same test's sources.
#
# POSITIVE CONTROL: the two corpus witnesses the pass was dispatched on —
# `ibex_tracer` (road B) and `StructParamFuncBodyFieldCompare` (road D) — must
# both come out of this scan.  If they do not, the scan is broken and a short
# list means nothing.
import os
import re
import sys

ROOTS = [
    ('surelog', os.path.expanduser('~/git-repos/Surelog/tests')),
    ('surelog', os.path.expanduser('~/git-repos/Surelog/third_party/tests')),
    ('uhdm2rtlil', os.path.expanduser('~/git-repos/uhdm2rtlil/test')),
]
EXTS = ('.sv', '.v', '.svh', '.vh')
PKG_OPEN = re.compile(r'\bpackage\s+(\w+)\s*;')
PKG_CLOSE = re.compile(r'\bendpackage\b')
PARAM = re.compile(r'\b(?:localparam|parameter)\b')
DECL = re.compile(r'([A-Za-z_]\w*)\s*(?:=|$)')


def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', t)


def sources_of(d0):
    srcs = []
    for dirpath, _dn, files in os.walk(d0):
        if 'slpp_all' in dirpath:
            continue
        for f in files:
            if f.endswith(EXTS):
                srcs.append(os.path.join(dirpath, f))
            elif f.endswith('.f'):
                fp = os.path.join(dirpath, f)
                try:
                    for ln in open(fp, errors='replace'):
                        ln = ln.split('//')[0].split('#')[0].strip()
                        if not ln or ln[0] in '-+':
                            continue
                        c = os.path.normpath(os.path.join(dirpath, ln))
                        if c.endswith(EXTS) and os.path.isfile(c):
                            srcs.append(c)
                except OSError:
                    pass
    return srcs


def pkg_params(t):
    """[(name, rhs)] for every package-scope parameter declaration."""
    out = []
    pos = 0
    while True:
        m = PKG_OPEN.search(t, pos)
        if not m:
            break
        e = PKG_CLOSE.search(t, m.end())
        body = t[m.end():e.start()] if e else t[m.end():]
        pos = e.end() if e else len(t)
        for pm in PARAM.finditer(body):
            sc = body.find(';', pm.end())
            eq = body.find('=', pm.end())
            if eq < 0 or (sc >= 0 and sc < eq):
                continue
            head = body[pm.end():eq]
            nm = DECL.findall(head)
            out.append((nm[-1] if nm else '?', body[eq + 1:sc]))
    return out


# a call argument written inside a `parameter`/`localparam` DECLARATION
CALLARG = re.compile(r'\w\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)')


def call_arg_names(t):
    names = set()
    for pm in PARAM.finditer(t):
        sc = t.find(';', pm.end())
        seg = t[pm.end():sc if sc > 0 else len(t)]
        for cm in CALLARG.finditer(seg):
            for w in re.findall(r'[A-Za-z_]\w*', cm.group(1)):
                names.add(w)
    # a module header parameter port list has no `;` terminator per item
    for hm in re.finditer(r'#\s*\(', t):
        depth, i = 0, hm.end() - 1
        while i < len(t):
            if t[i] == '(':
                depth += 1
            elif t[i] == ')':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        seg = t[hm.end():i]
        for cm in CALLARG.finditer(seg):
            for w in re.findall(r'[A-Za-z_]\w*', cm.group(1)):
                names.add(w)
    return names


def concat_reachable(rhs):
    """A `{` not preceded by `'`, with at least one identifier leaf, and not
    below a `?:` — the cheap textual stand-in for `concatBearing54`."""
    if '?' in rhs:
        return False
    for m in re.finditer(r'(?<!\')\{', rhs):
        # the brace's own body
        depth, i = 0, m.start()
        while i < len(rhs):
            if rhs[i] == '{':
                depth += 1
            elif rhs[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        inner = rhs[m.start():i]
        if re.search(r'[A-Za-z_]\w*', inner):
            return True
    return False


def main():
    rows = []
    for corpus, root in ROOTS:
        if not os.path.isdir(root):
            continue
        for name in sorted(os.listdir(root)):
            d0 = os.path.join(root, name)
            if not os.path.isdir(d0):
                continue
            texts = []
            for p in sources_of(d0):
                try:
                    texts.append(strip_comments(open(p, errors='replace').read()))
                except OSError:
                    pass
            if not any('package' in t for t in texts):
                continue
            argnames = set()
            for t in texts:
                argnames |= call_arg_names(t)
            b = d = False
            for t in texts:
                for pn, rhs in pkg_params(t):
                    if "'{" in rhs:
                        if pn in argnames:
                            d = True
                    elif concat_reachable(rhs):
                        b = True
            if b or d:
                rows.append((corpus, name, ('B' if b else '') + ('D' if d else '')))
    for c, n, k in rows:
        print(f'{c} {n} {k}')
    print(f'-- predicted={len(rows)}', file=sys.stderr)


main()
