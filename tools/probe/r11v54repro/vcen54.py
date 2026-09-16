#!/usr/bin/env python3
"""r11v54 (verifier) A-PRIORI CENSUS for § pkgElabConcatTreeNoFold54.

Names every test DIRECTORY whose sources declare a PACKAGE parameter or
localparam whose right-hand side carries a brace — the superset of what the
widened predicate can reach.  Deliberately CRUDE and deliberately a SUPERSET:
a census that models the predicate exactly would be the patch marking its own
homework.  The point is the POSITIVE CONTROL — the dispatched witness must
fall out of the scan — and the upper bound on the blast radius.

  usage: vcen54.py <corpus-root> [<corpus-root> ...]
"""
import os, re, sys

PKG = re.compile(r'^\s*package\s+\w+\s*;')
ENDPKG = re.compile(r'^\s*endpackage\b')
PARAM = re.compile(r'^\s*(localparam|parameter)\b')
EXTS = ('.sv', '.v', '.svh', '.vh')


def scan(path):
    try:
        lines = open(path, errors='replace').read().split('\n')
    except OSError:
        return False
    inpkg = False
    for i, l in enumerate(lines):
        if PKG.match(l):
            inpkg = True
            continue
        if ENDPKG.match(l):
            inpkg = False
            continue
        if not inpkg or not PARAM.match(l):
            continue
        # the declaration may wrap; look at up to three lines
        txt = ' '.join(lines[i:i + 3])
        rhs = txt.split('=', 1)[1] if '=' in txt else ''
        if '{' in rhs:
            return True
    return False


def main():
    hits = set()
    for root in sys.argv[1:]:
        for d, _, files in os.walk(root):
            for f in files:
                if f.endswith(EXTS) and scan(os.path.join(d, f)):
                    hits.add(d)
    for h in sorted(hits):
        print(h)
    print(f'---- {len(hits)} directories', file=sys.stderr)


main()
