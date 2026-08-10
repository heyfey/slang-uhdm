#!/usr/bin/env python3
"""r10uvm44 — CHECK THE SHAPE IS PRESENT BEFORE SPENDING A PASS ON IT.

The associative-INDEX rule has five copies in this emitter and each copy serves
a different DECLARATION SITE.  Whether fixing a given copy can move the corpus
depends entirely on whether that site's declaration shape occurs in it:

  site 1/2  emitAssocDims outer + inner   -> a CLASS PROPERTY
  site 3    makeQueueDynArrayVar          -> a SUBROUTINE LOCAL
  site 4    emitDynArrayVar               -> a MODULE / INTERFACE signal
  site 5    emitPkgArrayVar               -> a PACKAGE-scope declaration

and only a TYPEDEF-NAME index reaches the registry arm at all; a `[string]` or
`[int]` index was always handled by the keyword arms.

So this script finds associative-array declarations whose index is a plain
IDENTIFIER (not a type keyword and not a number), and reports the ENCLOSING
SCOPE KIND, which is what selects the site.

  usage: associdx.py <root> [root ...]
"""
import os
import re
import sys
from collections import Counter

KEYWORDS = {
    'int', 'integer', 'byte', 'shortint', 'longint', 'time', 'string', 'bit',
    'logic', 'reg', 'real', 'shortreal', 'chandle', 'event', 'unsigned',
    'signed', 'void', '$',
}
# `<something> <name> [<Identifier>];` -- an unpacked dimension holding a bare
# identifier is either an associative index or a parameter-sized fixed array;
# both are reported and the scope column is what matters here.
DECL = re.compile(r'^\s*(\w[\w:#\(\)\s,\.]*?)\s+(\w+)\s*\[\s*([A-Za-z_]\w*(?:::\w+)?)\s*\]\s*;')
OPEN = re.compile(r'^\s*(?:\w+\s*:\s*)?(module|interface|package|class|program|checker|function|task)\b')
CLOSE = re.compile(r'^\s*end(module|interface|package|class|program|checker|function|task)\b')
SV_EXT = ('.sv', '.svh', '.v', '.vh')


def scan(path):
    hits = []
    stack = []
    try:
        with open(path, 'r', errors='replace') as f:
            for line in f:
                line = line.split('//')[0]
                if CLOSE.match(line):
                    if stack:
                        stack.pop()
                    continue
                o = OPEN.match(line)
                # CORRECTED BY THE PASS-44 VERIFIER — the same broken guard
                # atomtd.py carried: `not line.endswith(';')` refuses to push
                # `package p;` / `module m;` / `module m(...);`, so every
                # package- and module-scope hit fell into $unit. The specific
                # claim (0 package-scope container declarations) survives the
                # corrected walk, but the printed DISTRIBUTION did not: reported
                # module 830 / $unit 483 / interface 60, actual module 929 /
                # interface 346 / class 70 / function 34 / $unit 14 — the
                # "$unit 483" was mostly Rsd interface bodies.
                head = line.split('//')[0].strip()
                if o and not (head.startswith('typedef') or
                              head.startswith('extern')):
                    stack.append(o.group(1))
                    continue
                m = DECL.match(line)
                if m and m.group(3) not in KEYWORDS and m.group(1) != 'typedef':
                    scope = stack[-1] if stack else '$unit'
                    hits.append((scope, m.group(3), m.group(2), line.strip()))
    except OSError:
        pass
    return hits


def main():
    per_scope = Counter()
    rows = []
    for root in sys.argv[1:]:
        for dirpath, _dirs, names in os.walk(root):
            for n in names:
                if not n.endswith(SV_EXT):
                    continue
                p = os.path.join(dirpath, n)
                for scope, idx, name, txt in scan(p):
                    per_scope[scope] += 1
                    rows.append((scope, idx, name, p, txt))
    for scope, n in sorted(per_scope.items(), key=lambda kv: -kv[1]):
        print('scope %-10s %d' % (scope, n))
    print()
    for scope, idx, name, p, txt in sorted(rows):
        print('%-10s [%s] %-28s %s' % (scope, idx, name, p))


if __name__ == '__main__':
    main()
