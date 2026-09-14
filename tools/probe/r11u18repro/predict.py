#!/usr/bin/env python3
"""A-PRIORI mover predictor for r11u14 (SS modEvalFuncLeftoverEnc).

From the SOURCES alone -- no patched binary, no database -- name every test that
can carry one of the law's leftover shapes.  A parameter is "of the family" when
its initializer calls a MEMBER-BY-MEMBER const function (a function whose body
writes `<local>.<member> = <expr>;` and returns the local).  UHDM v1.87's
`ExprEval::setValueInInstance` stamps `reduceExpr(<that RHS>)` on the struct
typespec's member, so the leftover's ENCODING is the reduced RHS object's, and
the HOLDER is irrelevant.  Four shapes move:

  LIT  ANY integer-literal RHS on a MODULE-held parameter.  A sized/based one
       changes the compared encoding (`r.base = 64'h1000` -> HEX ct 5 where the
       value slice gives UINT ct 9); a plain unsized decimal keeps all four
       compared fields but the leftover becomes the SHARED body object rather
       than a minted copy, which still MOVES BYTES               tag `LIT:`
  CAT  a CONCATENATION RHS, either holder (BIN at the SUM OF THE OPERAND
       SIZES, no decompile, no typespec)                            tag `CAT:`
  REP  a REPLICATION RHS, either holder (BIN at n x the element width, WITH a
       decompile and a typespec)                                    tag `REP:`
  RD   a WHOLE read of a formal or of another parameter on a MODULE-held
       parameter (the read object's own size/sign)                  tag `RD:`

The sources cannot know whether a member's RHS actually reduces, nor whether
the assembler BAILED on the holder -- that is what the drain decides -- so this
OVER-NAMES by design: the measured movers must be a SUBSET of what it names.

usage: predict.py <corpus-root> [names...]
  corpus-root: ~/git-repos/uhdm2rtlil/test   or  ~/git-repos/Surelog/tests

REACH CONTROL (the r11u13 lesson): the Surelog suite keeps its command lines in
`<Name>.sl` files one or two levels down, so `testdirs()` WALKS for them; a
one-level listdir sees nothing there and prints a green zero.  The count is
printed on stderr.

POSITIVE CONTROLS, all of which MUST be named:
  * `struct_param_func_arg` (uhdm2rtlil)  -- LIT, the `r.base = 64'h1000`
    leftover on a module holder; the row this pass converts.
  * `struct_param_func_loop` (uhdm2rtlil) -- CAT, the concat-built 192-bit
    member; the second row this pass converts.
NEGATIVE CONTROLS, none of which may be named:
  * none in the Surelog suite is excluded a priori: `FuncStructVal` IS named
    (its builder reads five FN-SCOPE LOCALS, which the predictor cannot tell
    from a parameter read) and is the BAIL witness -- one member is never
    written, so no stamp is recorded at all and its database must come back
    BYTE-IDENTICAL.  `Ariane2024` / `Verilator` are named and build NO database
    on either binary in either mode.
  * `pkg_nested_struct_param_width`, `portsel_struct_param` (uhdm2rtlil,
    CMP_EQUAL at this base) -- package holders whose members are plain decimal
    literals and whole reads that the landed package arm already resolves.
"""
import os
import re
import sys

FUNC = re.compile(
    r'\bfunction\b\s+(?:automatic\s+|static\s+)?[\w:]+(?:\s*\[[^\]]*\])?\s+(\w+)\s*[(;]')
# `<local>.<member> = <rhs>;`
MEMW = re.compile(r'^\s*(\w+)\s*\.\s*([\w.\[\]]+?)\s*=\s*([^;]+);', re.M)
# `localparam|parameter [type] NAME = [pkg::]fn(`  -- a builder-fed parameter
PCALL = re.compile(
    r'\b(?:localparam|parameter)\b([^;=]*?)\b(\w+)\s*=\s*(?:(\w+)\s*::\s*)?(\w+)\s*\(')
PKGDECL = re.compile(r'\bpackage\s+(\w+)\s*;')
# a sized/based literal (`64'h1000`, `1'b1`, `32'd64`, `8'o17`) or `'1`/`'0`
SIZED = re.compile(r"^(?:\d[\d_]*\s*)?'[sS]?[bBoOdDhH]?[0-9a-fA-FxXzZ_]+$")


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


def pkg_spans(t):
    out = []
    for m in PKGDECL.finditer(t):
        e = t.find('endpackage', m.end())
        out.append((m.group(1), m.end(), e if e >= 0 else len(t)))
    return out


def classify(rhs):
    """The leftover shape of one member-write RHS."""
    r = rhs.strip()
    if r.startswith('{'):
        # `{n{x}}` is a REPLICATION, `{a, b}` a plain CONCAT.
        inner = r[1:-1].strip() if r.endswith('}') else r[1:]
        return 'REP' if re.match(r'^[\w\']+\s*\{', inner) else 'CAT'
    if SIZED.match(r) or re.match(r'^[\d_]+$', r):
        # ANY integer literal: a sized/based one changes the leftover's
        # encoding, a plain unsized decimal keeps the same four compared fields
        # but the leftover becomes the SHARED body object instead of a minted
        # copy, which MOVES BYTES.  Both are named.
        return 'LIT'
    if re.match(r'^[\w:]+$', r):
        return 'RD'
    return ''


def builders(t):
    """{fn name: [(member, shape), ...]} for member-by-member builders."""
    out = {}
    for m in FUNC.finditer(t):
        e = t.find('endfunction', m.end())
        body = t[m.end():e if e >= 0 else len(t)]
        writes = MEMW.findall(body)
        if not writes:
            continue
        locals_ = {}
        for loc, mem, rhs in writes:
            locals_.setdefault(loc, []).append((mem, classify(rhs)))
        # the local the body builds is the one with the most member writes
        best = max(locals_.values(), key=len)
        if best:
            out[m.group(1)] = best
    return out


def hits(d):
    texts = [strip(x) for x in sources(d)]
    whole = '\n'.join(texts)
    bld = builders(whole)
    if not bld:
        return []
    spans = pkg_spans(whole)
    tags = []
    for m in PCALL.finditer(whole):
        pname, fn = m.group(2), m.group(4)
        if fn not in bld:
            continue
        inpkg = any(a <= m.start() < b for _n, a, b in spans)
        for mem, sh in bld[fn]:
            if sh == 'CAT':
                tags.append('CAT:%s.%s' % (pname, mem))
            elif sh == 'REP':
                tags.append('REP:%s.%s' % (pname, mem))
            elif not inpkg and sh == 'LIT':
                tags.append('LIT:%s.%s' % (pname, mem))
            elif not inpkg and sh == 'RD':
                tags.append('RD:%s.%s' % (pname, mem))
    return sorted(set(tags))


def testdirs(root):
    """Every test directory under `root` (WALK -- see REACH CONTROL)."""
    out = {}
    for r, _dd, fs in os.walk(root):
        if any(f.endswith(('.sl', '.sv', '.v')) for f in fs):
            # a uhdm2rtlil test is a direct child of root; a Surelog test is
            # the directory holding its `<Name>.sl`
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
            print('%-40s %s' % (name, ' '.join(t)))
    print('# named: %d' % n, file=sys.stderr)


main()
