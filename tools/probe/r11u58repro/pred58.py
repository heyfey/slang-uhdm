#!/usr/bin/env python3
# r11u58 A-PRIORI MOVER PREDICTION, BY NAME, written BEFORE the patched sweep.
#
# The gate this models is § pkgElabPatMemberStamp58:
#   a PACKAGE parameter/localparam whose Rhs is an ASSIGNMENT PATTERN `'{...}`
#   AND whose name is written as `pkg::NAME` INSIDE A CALL that itself stands
#   inside a PARAMETER CONTEXT (a parameter port default, a body localparam,
#   or an instance `#(...)` override actual).
# The scan is deliberately a SUPERSET of the compiled gate: it does not check
# that the struct is PACKED, that the pattern is STRUCTURED, or that our
# exporter keeps the tagged tree for it — every one of those only REMOVES rows.
#
# POSITIVE CONTROL: the dispatched witness `StructParamFuncBodyFieldCompare`
# and the must-not-move row `FuncStructVal` must BOTH fall out of this scan.
# If they do not, the scan is broken and a short list means nothing.
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
CALL = re.compile(r'[A-Za-z_]\w*(?:::[A-Za-z_]\w*)?\s*\(')
QUAL = re.compile(r'\b([A-Za-z_]\w*)::([A-Za-z_]\w*)\b')


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


def pkg_pattern_params(t):
    """{pkg::NAME} for every package-scope parameter whose Rhs is a pattern."""
    out = set()
    pos = 0
    while True:
        m = PKG_OPEN.search(t, pos)
        if not m:
            break
        pkg = m.group(1)
        e = PKG_CLOSE.search(t, m.end())
        body = t[m.end():e.start()] if e else t[m.end():]
        pos = e.end() if e else len(t)
        for pm in PARAM.finditer(body):
            sc = body.find(';', pm.end())
            eq = body.find('=', pm.end())
            if eq < 0 or (sc >= 0 and sc < eq):
                continue
            nm = DECL.findall(body[pm.end():eq])
            if nm and "'{" in body[eq + 1:sc]:
                out.add(pkg + '::' + nm[-1])
    return out


def balanced(t, i):
    """t[i] is '('; return the index of its match."""
    depth = 0
    while i < len(t):
        if t[i] == '(':
            depth += 1
        elif t[i] == ')':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return len(t)


def call_arg_quals(seg):
    """Every `pkg::NAME` written inside a CALL's argument list in `seg`."""
    out = set()
    for cm in CALL.finditer(seg):
        op = seg.find('(', cm.start())
        cl = balanced(seg, op)
        for q in QUAL.finditer(seg[op + 1:cl]):
            out.add(q.group(1) + '::' + q.group(2))
    return out


def param_context_quals(t):
    """Call-argument `pkg::NAME`s inside parameter declarations, module header
    parameter port lists, and instance `#(...)` override actuals."""
    out = set()
    for pm in PARAM.finditer(t):
        sc = t.find(';', pm.end())
        out |= call_arg_quals(t[pm.end():sc if sc > 0 else len(t)])
    for hm in re.finditer(r'#\s*\(', t):
        op = t.find('(', hm.start())
        out |= call_arg_quals(t[op + 1:balanced(t, op)])
    return out


def main():
    rows = []
    for corpus, root in ROOTS:
        if not os.path.isdir(root):
            continue
        for name in sorted(os.listdir(root)):
            d0 = os.path.join(root, name)
            if not os.path.isdir(d0):
                continue
            pats, quals = set(), set()
            for p in sources_of(d0):
                try:
                    t = strip_comments(open(p, errors='replace').read())
                except OSError:
                    continue
                pats |= pkg_pattern_params(t)
                quals |= param_context_quals(t)
            hit = sorted(pats & quals)
            if hit:
                rows.append((corpus, name, ','.join(hit)))
    for c, n, h in rows:
        print(f'{c} {n} {h}')
    print(f'-- predicted={len(rows)}', file=sys.stderr)


main()
