#!/usr/bin/env python3
"""r11u3 A-PRIORI MOVER PREDICTOR for § structParamMemberOvBinary.

Names, from the PRISTINE side alone (the test's own sources plus the PRISTINE
database), every test whose bytes the law can move.  Run it BEFORE the patched
sweep; the answer must then equal the byteverify mover set exactly.

THE PREDICATE (both halves must hold):

  (a) SOURCE half — the test compiles a module instantiation whose parameter
      override list carries an actual that is a BARE MEMBER SELECT,
      `.FORMAL(BASE.MEMBER)` or the positional `(BASE.MEMBER)`, with nothing
      around it (no operator, no index, no call).  That is the only shape the
      law's arm accepts.

  (b) DATABASE half — the PRISTINE database emitted for that test contains a
      `parameter` whose typespec resolves to a `struct_typespec` AND whose
      name is one of the BASEs found in (a).  A dotted actual whose base is
      not a struct-typed parameter (a hierarchical instance path, an interface
      port, a package-qualified constant) is NOT this family.

Half (a) alone over-predicts (it cannot tell a struct parameter from an
interface reference); half (b) alone over-predicts far worse (every design
with a struct parameter).  The conjunction is the law's own gate.

usage:  predict.py <verify_golden workdir>/<mode>   [name ...]
        (with no names, every test directory in that mode is scanned)

Measurement-only.  The judge is uhdm-cmp through scripts/verify_golden.py.
"""
import os
import re
import subprocess
import sys

UHDM_DUMP = os.path.expanduser('~/git-repos/UHDM/build/bin/uhdm-dump')

# `.F(A.B)` / `.F(A.B.C)` and the positional `(A.B)` — the WHOLE actual is the
# dotted path, so the closing paren follows the last identifier directly.
DOTTED = re.compile(r'[.(]\s*[A-Za-z_$][\w$]*\s*\(\s*([A-Za-z_$][\w$]*)'
                    r'(?:\s*\.\s*[A-Za-z_$][\w$]*)+\s*\)')
BARE = re.compile(r'\(\s*([A-Za-z_$][\w$]*)(?:\s*\.\s*[A-Za-z_$][\w$]*)+\s*\)')
COMMENT = re.compile(r'//[^\n]*|/\*.*?\*/', re.S)


def sources_of(cmds):
    """The source files on the slang command line of a verify_golden row."""
    line = ''
    for ln in open(cmds, encoding='utf-8', errors='replace'):
        if ln.startswith('slang:'):
            line = ln[len('slang:'):].strip()
    out = []
    toks = line.split()
    skip = False
    for i, t in enumerate(toks):
        if skip:
            skip = False
            continue
        if t in ('-o', '-y', '-I', '-v'):
            skip = True
            continue
        if t.startswith('-') or t.endswith('slang-uhdm') or t.endswith('.bin'):
            continue
        if t.endswith(('.sv', '.v', '.svh', '.vh')):
            out.append(t)
    return out


HOME = os.path.expanduser('~')
ROOTS = [os.path.join(HOME, 'git-repos', 'uhdm2rtlil', 'test'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'tests'),
         os.path.join(HOME, 'git-repos', 'Surelog', 'third_party', 'tests')]


def test_root(name):
    """verify_golden runs each row with cwd = the test's own source dir."""
    for r in ROOTS:
        d = os.path.join(r, name)
        if os.path.isdir(d):
            return d
    return None


def bases_in_sources(srcs, root):
    bases = set()
    for s in srcs:
        p = s if os.path.isabs(s) else os.path.join(root or '', s)
        if not os.path.isfile(p):
            continue
        txt = COMMENT.sub(' ', open(p, encoding='utf-8', errors='replace').read())
        for m in DOTTED.finditer(txt):
            bases.add(m.group(1))
        for m in BARE.finditer(txt):
            bases.add(m.group(1))
    return bases


def struct_params(db):
    """Names of parameters whose typespec resolves to a struct_typespec."""
    try:
        txt = subprocess.run([UHDM_DUMP, db], capture_output=True, text=True,
                             timeout=900).stdout
    except Exception:
        return set()
    names = set()
    lines = txt.split('\n')
    for i, ln in enumerate(lines):
        m = re.search(r'\\_parameter: \(([^)]*)\)', ln)
        if not m:
            continue
        nm = m.group(1).split('.')[-1]
        # the parameter's own ref_typespec actual, within its printed block
        for j in range(i + 1, min(i + 14, len(lines))):
            s = lines[j].strip()
            if s.startswith('\\_struct_typespec:'):
                names.add(nm)
                break
            if s.startswith('\\_parameter:'):
                break
    return names


def main():
    mode_dir = sys.argv[1]
    want = set(sys.argv[2:])
    for d in sorted(os.listdir(mode_dir)):
        full = os.path.join(mode_dir, d)
        name = d.rsplit('-', 1)[0]
        if want and name not in want:
            continue
        cmds = os.path.join(full, 'cmds.txt')
        db = os.path.join(full, 'slang.uhdm')
        if not os.path.isfile(cmds) or not os.path.isfile(db):
            continue
        srcs = sources_of(cmds)
        root = test_root(name)
        if root is None and srcs and os.path.isabs(srcs[0]):
            root = os.path.dirname(srcs[0])
        bases = bases_in_sources(srcs, root)
        if not bases:
            print('%-70s False (no dotted actual)' % name)
            continue
        sp = struct_params(db)
        hit = sorted(bases & sp)
        print('%-70s %s%s' % (name, bool(hit), (' ' + ','.join(hit)) if hit else ''))


if __name__ == '__main__':
    main()
