#!/usr/bin/env python3
# r11u54 CENSUS — the a-priori mover prediction, BY NAME, from the SOURCES.
#
# Both of this pass's laws fire in ONE place: the ELABORATED listing of a
# PACKAGE parameter.  So a test can only move if one of its sources declares a
# package whose parameter/localparam initializer carries
#   ROAD B: a concatenation `{...}` or a replication `{N{...}}` anywhere in the
#           Rhs tree below a binary/unary op or a cast (NOT below a
#           conditional, and NOT an assignment pattern `'{...}`), or
#   ROAD D: an assignment pattern `'{...}` (the tagged-member form).
# The scan is deliberately a SUPERSET (it does not parse): it flags a package
# parameter whose Rhs text contains `{` at all, splitting `'{` (road D) from a
# bare `{` (road B).  Every byte mover the sweeps find must be on this list.
#
# usage: cen54.py  -> prints "<corpus> <testdir-name> B|D|BD"
import os
import re
import sys

ROOTS = [
    ('surelog', os.path.expanduser('~/git-repos/Surelog/tests')),
    ('surelog', os.path.expanduser('~/git-repos/Surelog/third_party/tests')),
    ('uhdm2rtlil', os.path.expanduser('~/git-repos/uhdm2rtlil/test')),
]
EXTS = ('.sv', '.v', '.svh', '.vh')

PKG_OPEN = re.compile(r'\bpackage\s+\w+\s*;')
PKG_CLOSE = re.compile(r'\bendpackage\b')
PARAM = re.compile(r'\b(?:localparam|parameter)\b')


def strip_comments(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', ' ', t)
    return t


def scan_text(t):
    """Return (roadB, roadD) for one file's text."""
    t = strip_comments(t)
    b = d = False
    pos = 0
    while True:
        m = PKG_OPEN.search(t, pos)
        if not m:
            break
        e = PKG_CLOSE.search(t, m.end())
        body = t[m.end():e.start()] if e else t[m.end():]
        pos = e.end() if e else len(t)
        # every `= ... ;` that follows a parameter keyword in the package body
        for pm in PARAM.finditer(body):
            eq = body.find('=', pm.end())
            sc = body.find(';', pm.end())
            if eq < 0 or (sc >= 0 and sc < eq):
                continue
            rhs = body[eq + 1:sc if sc > eq else len(body)]
            if "'{" in rhs:
                d = True
            if re.search(r"(?<!')\{", rhs):
                b = True
    return b, d


def main():
    out = []
    for corpus, root in ROOTS:
        if not os.path.isdir(root):
            continue
        for name in sorted(os.listdir(root)):
            d0 = os.path.join(root, name)
            if not os.path.isdir(d0):
                continue
            b = d = False
            srcs = []
            for dirpath, _dn, files in os.walk(d0):
                if 'slpp_all' in dirpath or '/build' in dirpath:
                    continue
                for f in files:
                    if f.endswith(EXTS):
                        srcs.append(os.path.join(dirpath, f))
            # a `project.f` / `*.f` filelist names sources OUTSIDE the test dir
            # (uhdm2rtlil's ibex_tracer pulls ../ibex/rtl/*.sv) — follow them,
            # or the census misses the pass's own u2r witness.
            for dirpath, _dn, files in os.walk(d0):
                for f in files:
                    if not f.endswith('.f'):
                        continue
                    fp = os.path.join(dirpath, f)
                    try:
                        with open(fp, errors='replace') as fh:
                            for ln in fh:
                                ln = ln.split('//')[0].split('#')[0].strip()
                                if not ln or ln.startswith('-') or \
                                        ln.startswith('+'):
                                    continue
                                cand = os.path.normpath(
                                    os.path.join(dirpath, ln))
                                if cand.endswith(EXTS) and os.path.isfile(cand):
                                    srcs.append(cand)
                    except OSError:
                        pass
            for p in srcs:
                try:
                    with open(p, errors='replace') as fh:
                        t = fh.read()
                except OSError:
                    continue
                if 'package' not in t:
                    continue
                b2, d2 = scan_text(t)
                b = b or b2
                d = d or d2
                if b and d:
                    break
            if b or d:
                out.append((corpus, name, ('B' if b else '') + ('D' if d else '')))
    for c, n, k in out:
        print(f'{c} {n} {k}')
    print(f'-- candidates={len(out)}', file=sys.stderr)


main()
