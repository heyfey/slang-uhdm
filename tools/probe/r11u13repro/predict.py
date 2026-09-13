#!/usr/bin/env python3
"""A-PRIORI mover predictor for r11u13 (SS asmEncFollowsRef).

From the SOURCES alone -- no patched binary, no database -- name every test that
can carry one of the law's three shapes.  A parameter is "of the family" when
its initializer calls a MEMBER-BY-MEMBER const function (a function whose body
writes `<local>.<member> = ...`); v1.87's `reduceExpr(struct_var)` assembler
reduces such a parameter to ONE packed BIN constant wherever it does not BAIL,
and these three sites must follow that encoding:

  R1  a parameter DEFAULTED to a bare reference to such a parameter
      (`parameter cfg_t Cfg = p::C`)                     -> tag `R1:<param>=<base>`
  R2  an instantiation override actual that is a BARE REFERENCE to such a
      parameter, or to a parameter that is itself R1-chained to one
      (`child #(.Cfg(Cfg))`, `holder #(.H(p::C))`)       -> tag `R2:.<formal>(<base>)`
  R3  a MODULE that IMPORTS a package holding such a localparam: the
      materialized import copy's ELABORATED param_assign Rhs carries the
      `<w>'b` prefix where the DEF listing keeps the assembler's bare bits
                                                          -> tag `R3:import <pkg>`

The sources cannot know whether the assembler BAILED on a given base (that is
what the drain decides), so this OVER-NAMES by design: the measured movers must
be a SUBSET of what it names.

usage: predict.py <corpus-root> [names...]
  corpus-root: ~/git-repos/uhdm2rtlil/test   or  ~/git-repos/Surelog/tests

POSITIVE CONTROL: `struct_param_func_config` (uhdm2rtlil) must be named on ALL
THREE tags -- it is the row this pass converts, and it carries R1, R2 and R3 in
one design.
NEGATIVE CONTROLS, all of which must NOT be named:
  * `FuncStructValSimple` / `FuncStructVal` (surelog) -- r11u11's converted row
    and its BAIL witness: a MODULE holder read through a MEMBER SELECT, no bare
    reference and no package import of the holder.  They must stay
    byte-identical.
  * `pkg_nested_struct_param_width`, `portsel_struct_param` (uhdm2rtlil,
    CMP_EQUAL at this base) -- both carry the builder, neither imports the
    package into a module nor reads the parameter through a bare reference.
"""
import os
import re
import sys

FUNC = re.compile(
    r'\bfunction\b\s+(?:automatic\s+|static\s+)?[\w:]+(?:\s*\[[^\]]*\])?\s+(\w+)\s*[(;]')
MEMW = re.compile(r'\b\w+\s*\.\s*\w+\s*=[^=]')
# `localparam|parameter [type] NAME = [pkg::]fn(`   -- a builder-fed parameter
PCALL = re.compile(
    r'\b(?:localparam|parameter)\b([^;=]*?)\b(\w+)\s*=\s*(?:(\w+)\s*::\s*)?(\w+)\s*\(')
# `localparam|parameter [type] NAME = [pkg::]OTHER ;`  -- a BARE-REFERENCE default
PREF = re.compile(
    r'\b(?:localparam|parameter)\b([^;=]*?)\b(\w+)\s*=\s*(?:(\w+)\s*::\s*)?(\w+)\s*[;,)]')
# `.FORMAL ( [pkg::]BASE )` -- a bare reference as the WHOLE actual
OVREF = re.compile(r'\.\s*(\w+)\s*\(\s*(?:(\w+)\s*::\s*)?(\w+)\s*\)')
PKGDECL = re.compile(r'\bpackage\s+(\w+)\s*;')
IMPORT = re.compile(r'\bimport\s+(\w+)\s*::\s*(?:\*|\w+)')


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


def pkg_spans(t):
    """(name, start, end) for every `package <n>; ... endpackage`."""
    out = []
    for m in PKGDECL.finditer(t):
        e = t.find('endpackage', m.end())
        out.append((m.group(1), m.end(), e if e >= 0 else len(t)))
    return out


def hits(d):
    texts = [strip(x) for x in sources(d)]
    whole = '\n'.join(texts)
    fns = builder_names(whole)
    if not fns:
        return []
    # THE FAMILY: parameters whose initializer calls one of those builders.
    bases = set()
    for _pre, pname, _scope, fn in PCALL.findall(whole):
        if fn in fns:
            bases.add(pname)
    if not bases:
        return []
    tags = []
    # R1 -- and the transitive closure, because an R1 parameter is itself a
    # legal R2 base (`.Cfg(Cfg)` where `Cfg = p::C`).
    # NB: the tag and the chain growth are SEPARATE.  A module parameter very
    # often RE-USES the package localparam's own name (`parameter pk::cfg_t CFG
    # = pk::CFG`, param_nested_struct_field_width) — folding the tag into the
    # `not yet chained` test dropped that spelling and the predictor missed a
    # measured mover.
    chained = set(bases)
    for _ in range(4):
        for _pre, pname, _scope, rname in PREF.findall(whole):
            if rname not in chained:
                continue
            t9 = 'R1:%s=%s' % (pname, rname)
            if t9 not in tags:
                tags.append(t9)
            chained.add(pname)
    # R2
    for formal, _scope, actual in OVREF.findall(whole):
        if actual in chained:
            tags.append('R2:.%s(%s)' % (formal, actual))
    # R3 -- a package holding a family localparam, imported by a MODULE.
    fampkgs = set()
    for name, a, b in pkg_spans(whole):
        body = whole[a:b]
        for _pre, pname, _scope, fn in PCALL.findall(body):
            if fn in fns and pname in bases:
                fampkgs.add(name)
    if fampkgs:
        outside = re.sub(r'\bpackage\s+\w+\s*;.*?\bendpackage', ' ', whole,
                         flags=re.S)
        for pkg in sorted(set(m.group(1) for m in IMPORT.finditer(outside))):
            if pkg in fampkgs:
                tags.append('R3:import %s' % pkg)
    return sorted(set(tags))


def testdirs(root):
    """uhdm2rtlil: one test per immediate subdir.  Surelog: one test per `.sl`
    file, found by os.walk exactly as `verify_golden.py::discover_surelog`
    scans (the suite nests them; a one-level listdir SEES NOTHING and prints a
    green zero -- a census zero needs a positive control)."""
    out = []
    for dirpath, _dirs, files in os.walk(root):
        for fn in sorted(files):
            if fn.endswith('.sl'):
                out.append((fn[:-3], dirpath))
    if out:
        return sorted(set(out))
    return sorted((n, os.path.join(root, n)) for n in os.listdir(root)
                  if os.path.isdir(os.path.join(root, n)))


def main():
    root = sys.argv[1]
    names = sys.argv[2:]
    for n, d in testdirs(root):
        if names and n not in names:
            continue
        h = hits(d)
        if h:
            print('%s\t%s' % (n, ', '.join(h)))


if __name__ == '__main__':
    main()
