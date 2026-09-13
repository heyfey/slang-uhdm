#!/usr/bin/env python3
"""A-PRIORI mover predictor for r11u16 (SS caAsmMemberSliceFold).

From the SOURCES alone — no patched binary, no database — name every test that
can carry the law's shape:

    assign <target> = <P>.<member>;        (and `<pkg>::<P>.<member>`)

where `<P>` is a parameter or localparam whose value comes, possibly through a
chain of BARE references, from a MEMBER-BY-MEMBER const function (a function
whose body writes `<local>.<member> = <expr>;` and returns the local).  Only a
CONTINUOUS assignment counts: the fold this law models is
`UhdmWriter::writeCont_assign`'s whole-Rhs `reduceExpr`, so a procedural read,
a port connection or a range bound is a different site (grid `d10`, 0 cells).

Tags:
  CA:   the member select is the WHOLE Rhs of a continuous assign — the shape
        the law folds.
  NDA:  the same select as a NET-DECLARATION assign (`wire [7:0] w = P.m;`).
        Golden folds it too; this law does not reach that emission site, so it
        is named as a REACH check, never as an expected mover.
  ~NEST the holder's struct has a PACKED-STRUCT member, which the law's fence
        declines outright (grid `d13`).  Named so the fence is auditable.

The sources cannot know whether the producer's assembler ACTUALLY assembled the
base (that is what the drain decides) nor whether our own answer agrees with
golden's, so this OVER-NAMES by design: the measured movers must be a SUBSET of
what it names.

usage: predict.py <corpus-root> [names...]
  corpus-root: ~/git-repos/uhdm2rtlil/test   or  ~/git-repos/Surelog/tests

REACH CONTROL (the r11u13 lesson): the Surelog suite keeps its command lines in
`<Name>.sl` files one or two levels down, so `testdirs()` WALKS for them; a
one-level listdir sees nothing there and prints a green zero.  The count is
printed on stderr.
"""
import os
import re
import sys

FUNC = re.compile(
    r'\bfunction\b\s+(?:automatic\s+|static\s+)?[\w:]+(?:\s*\[[^\]]*\])?\s+(\w+)\s*[(;]')
MEMW = re.compile(r'^\s*(\w+)\s*\.\s*([\w.\[\]]+?)\s*=\s*([^;]+);', re.M)
# `localparam|parameter [type] NAME = <init>;`  (or `= <init>)` in a header)
PDECL = re.compile(
    r'\b(?:localparam|parameter)\b([^;=]*?)\b(\w+)\s*=\s*([^;,)]+)')
TYPEDEF = re.compile(r'\btypedef\s+struct\s+packed\s*\{(.*?)\}\s*(\w+)\s*;', re.S)
# a continuous assign whose RHS is exactly `[pkg::]NAME.member`
CA = re.compile(r'\bassign\b[^;]*?=\s*(?:(\w+)\s*::\s*)?(\w+)\s*\.\s*(\w+)\s*[;,]')
# a net-declaration assign of the same shape
NDA = re.compile(
    r'\b(?:wire|logic|reg|bit)\b[^;=]*?=\s*(?:(\w+)\s*::\s*)?(\w+)\s*\.\s*(\w+)\s*[;,]')


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


def builders(t):
    """names of member-by-member builder functions."""
    out = set()
    for m in FUNC.finditer(t):
        e = t.find('endfunction', m.end())
        body = t[m.end():e if e >= 0 else len(t)]
        if MEMW.findall(body):
            out.add(m.group(1))
    return out


def nested_structs(t):
    """typedef names whose packed struct has a member of a struct type."""
    names = set(m.group(2) for m in TYPEDEF.finditer(t))
    out = set()
    for m in TYPEDEF.finditer(t):
        body, nm = m.group(1), m.group(2)
        for ln in body.split(';'):
            w = ln.split()
            if w and (w[0] in names or w[0].split('::')[-1] in names):
                out.add(nm)
    return out


def family_params(t, bld):
    """{param name: declared type name} for parameters fed by a builder,
    following a chain of BARE references (`localparam cfg_t L = C;`)."""
    fam = {}
    for _round in range(4):
        grew = False
        for m in PDECL.finditer(t):
            decl, nm, init = m.group(1), m.group(2), m.group(3).strip()
            if nm in fam:
                continue
            call = re.match(r'^(?:\w+\s*::\s*)?(\w+)\s*\(', init)
            bare = re.match(r'^(?:\w+\s*::\s*)?(\w+)\s*$', init)
            hit = False
            if call and call.group(1) in bld:
                hit = True
            elif bare and bare.group(1) in fam:
                hit = True
            if hit:
                ty = ''
                for w in decl.split():
                    if w not in ('signed', 'unsigned') and not w.startswith('['):
                        ty = w.split('::')[-1]
                fam[nm] = ty
                grew = True
        if not grew:
            break
    return fam


def hits(d):
    whole = '\n'.join(strip(x) for x in sources(d))
    bld = builders(whole)
    if not bld:
        return []
    fam = family_params(whole, bld)
    if not fam:
        return []
    nest = nested_structs(whole)
    tags = []
    for pat, tag in ((CA, 'CA'), (NDA, 'NDA')):
        for m in pat.finditer(whole):
            base, mem = m.group(2), m.group(3)
            if base not in fam:
                continue
            t = '%s:%s.%s' % (tag, base, mem)
            if fam[base] in nest:
                t += '~NEST'
            tags.append(t)
    return sorted(set(tags))


def testdirs(root):
    """Every test directory under `root` (WALK — see REACH CONTROL)."""
    out = {}
    for r, _dd, fs in os.walk(root):
        if any(f.endswith(('.sl', '.sv', '.v')) for f in fs):
            rel = os.path.relpath(r, root)
            if rel == '.':
                continue
            out.setdefault(rel.split(os.sep)[0]
                           if not any(f.endswith('.sl') for f in fs)
                           else os.path.basename(r), r)
    return out


def main():
    root = os.path.expanduser(sys.argv[1])
    want = set(sys.argv[2:])
    dirs = testdirs(root)
    print('# test dirs reached: %d' % len(dirs), file=sys.stderr)
    n = 0
    for name in sorted(dirs):
        if want and name not in want:
            continue
        t = hits(dirs[name])
        if t:
            n += 1
            print('%-42s %s' % (name, ' '.join(t)))
    print('# named: %d' % n, file=sys.stderr)


main()
