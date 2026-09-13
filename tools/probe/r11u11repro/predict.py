#!/usr/bin/env python3
"""A-PRIORI mover predictor for r11u11 (SS memSelAsmBaseOv).

From the SOURCES alone -- no patched binary, no database -- name every test that
can carry the law's shape:

  a BARE MEMBER SELECT of a struct-typed parameter, used as the WHOLE actual of
  an instantiation parameter override, where that parameter's own initializer is
  a call to a MEMBER-BY-MEMBER const function (`<local>.<member> = <expr>;` in
  the body).

The law re-keys SS structParamMemberOvBinary's base fence for exactly that
shape, so a test without it cannot move; a test with it moves only when the
v1.87 assembler did not BAIL on the base (which the sources cannot tell -- that
is what the drain decides), so this over-names by design.

usage: predict.py <corpus-root> [names...]
  corpus-root: ~/git-repos/uhdm2rtlil/test   or  ~/git-repos/Surelog/tests

Prints one line per candidate:  <test>\t<Param>.<member> -> .<formal>  [,...]

POSITIVE CONTROL: FuncStructValSimple (surelog) must be named -- it is the row
this pass converts.  FuncStructVal must ALSO be named (identical shape, base
bails, byte-identical) -- a predictor that names only the converting row is
keyed on the answer, not on the shape.
NEGATIVE CONTROL: pkg_nested_struct_param_width / portsel_struct_param (r11u9's
conversions) must NOT be named -- they carry the builder but no member-select
override actual.
"""
import os
import re
import sys

FUNC = re.compile(
    r'\bfunction\b\s+(?:automatic\s+|static\s+)?[\w:]+(?:\s*\[[^\]]*\])?\s+(\w+)\s*[(;]')
MEMW = re.compile(r'\b\w+\s*\.\s*\w+\s*=[^=]')
# `localparam|parameter [type] NAME = [pkg::]fn(`   -- the builder-fed parameter
PDECL = re.compile(
    r'\b(?:localparam|parameter)\b([^;]*?)\b(\w+)\s*=\s*(?:(\w+)\s*::\s*)?(\w+)\s*\(')
# `.FORMAL ( BASE . MEMBER )` -- the whole actual, nothing else in the parens
OVACT = re.compile(r'\.\s*(\w+)\s*\(\s*(?:\w+\s*::\s*)?(\w+)\s*\.\s*(\w+)\s*\)')


def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', t)


def sources(d):
    out = []
    for root, _dirs, fs in os.walk(d):
        for f in sorted(fs):
            if f.endswith(('.sv', '.v', '.svh', '.vh')):
                try:
                    out.append(open(os.path.join(root, f), encoding='utf-8',
                                    errors='replace').read())
                except OSError:
                    pass
    return out


def builder_names(t):
    """Names of functions whose body writes its result member by member."""
    fns = set()
    for m in re.finditer(FUNC, t):
        tail = t[m.end():]
        e = tail.find('endfunction')
        if MEMW.search(tail[:e if e >= 0 else len(tail)]):
            fns.add(m.group(1))
    return fns


def hits(d):
    res = []
    texts = [strip(x) for x in sources(d)]
    whole = '\n'.join(texts)
    fns = builder_names(whole)
    if not fns:
        return res
    # parameters whose initializer calls one of those builders
    bases = set()
    for _pre, pname, _scope, fn in PDECL.findall(whole):
        if fn in fns:
            bases.add(pname)
    if not bases:
        return res
    for formal, base, member in OVACT.findall(whole):
        if base in bases:
            res.append('%s.%s -> .%s' % (base, member, formal))
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
        print('%s\t%s' % (n, ', '.join(h)))
