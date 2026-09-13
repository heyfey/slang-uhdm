#!/usr/bin/env python3
"""A-PRIORI mover predictor for r11u9 (the struct-assembler family).

From the SOURCES alone -- no patched binary, no database -- name every test
whose design carries the law's shape and say WHICH HALF it carries:

  pkg <pkg>::<fn>   a PACKAGE localparam whose initializer is a CALL to a
                    function of that package whose body writes its result
                    MEMBER BY MEMBER (`<local>.<member> = <expr>;`).
                    -> the assembled BIN Rhs + the leftover stamp
                       (SS pkgStructFuncAssembleBin), and every module that
                       WILDCARD-IMPORTS the package carries a copy that moves
                       with it.
  mod <pkg>::<fn>   the same call initialising a MODULE parameter or a
                    module-scope localparam.
                    -> the drain's struct_var -> assembled-constant swap
                       (SS modStructFuncAssembleBin), which the assembler's own
                       bail rule may DECLINE (a member with no leftover value:
                       FuncStructVal).

usage: predict.py <corpus-root> [names...]
  corpus-root: ~/git-repos/uhdm2rtlil/test   or  ~/git-repos/Surelog/tests

POSITIVE CONTROLS (uhdm2rtlil): pkg_nested_struct_param_width and
portsel_struct_param are named and both CONVERT.
NEGATIVE CONTROLS: FuncStructVal / FuncStructValSimple are named `mod` only
(their builder-fed parameter is a module parameter, their package localparams
are PATTERNS, not calls); FuncStructVal's assembler then BAILS and the row is
byte-identical.  struct_param_dim / iface_param_2level are named at all.
"""
import os
import re
import sys

FUNC = re.compile(
    r'\bfunction\b\s+(?:automatic\s+|static\s+)?[\w:]+(?:\s*\[[^\]]*\])?\s+(\w+)\s*[(;]')
PKG = re.compile(r'\bpackage\b\s+(\w+)\s*;(.*?)\bendpackage\b', re.S)
CALL = re.compile(
    r'\b(?:localparam|parameter)\b[^;=]*?=\s*(?:(\w+)\s*::\s*)?(\w+)\s*\(', re.S)
MEMW = re.compile(r'\b\w+\s*\.\s*\w+\s*=[^=]')


def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', t)


def sources(d):
    out = []
    for root, _dirs, fs in os.walk(d):
        for f in fs:
            if f.endswith(('.sv', '.v', '.svh', '.vh')):
                try:
                    out.append(open(os.path.join(root, f), encoding='utf-8',
                                    errors='replace').read())
                except OSError:
                    pass
    return out


def builders(body):
    """member-by-member builder functions declared in `body`, name -> body."""
    fns = {}
    for m in re.finditer(FUNC, body):
        tail = body[m.end():]
        e = tail.find('endfunction')
        b = tail[:e if e >= 0 else len(tail)]
        if MEMW.search(b):
            fns[m.group(1)] = b
    return fns


def hits(d):
    res = []
    for txt in sources(d):
        t = strip(txt)
        allfns = {}
        pkgtext = []
        for m in PKG.finditer(t):
            pname, body = m.group(1), m.group(2)
            fns = builders(body)
            for f in fns:
                allfns[f] = pname
            pkgtext.append((m.start(), m.end()))
            for _scope, fn in CALL.findall(body):
                if fn in fns:
                    res.append('pkg %s::%s' % (pname, fn))
        # everything OUTSIDE every package block is the MODULE holder half
        rest = list(t)
        for a, b in pkgtext:
            for i in range(a, b):
                rest[i] = ' '
        rest = ''.join(rest)
        for _scope, fn in CALL.findall(rest):
            if fn in allfns:
                res.append('mod %s::%s' % (allfns[fn], fn))
    return sorted(set(res))


root = sys.argv[1]
names = sys.argv[2:]
for n in sorted(os.listdir(root)):
    if names and n not in names:
        continue
    d = os.path.join(root, n)
    if not os.path.isdir(d):
        continue
    h = hits(d)
    if h:
        print('%s\t%s' % (n, ','.join(h)))
