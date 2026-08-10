#!/usr/bin/env python3
"""r10uvm44 — MEASURE THE MEASURER: the real corpus population of the shape
pass 43 ranked #1.

Pass 43's reach figure ("93 atom-typedef declarations across 52 files") came
from

  grep -rhoE '^[[:space:]]*typedef[[:space:]]+(int|byte|...)[[:space:]]+[A-Za-z_]'

and that regex does NOT select the shape the law needs.  It counts

  * ARRAY typedefs -- `typedef int unsigned RET_T[CNT];`, `typedef int triple
    [1:3];` -- whose canonical kind is FixedSizeUnpackedArrayType, handled by a
    DIFFERENT arm entirely;
  * CLASS-scope and $unit-scope typedefs, which are not the module/package
    listing loops at all;
  * C/C++ headers (`.h`, `.cpp`) that are never compiled as SystemVerilog;
  * and it says nothing about the ENCLOSING SCOPE, which is the whole
    distinction between the arm that already existed (package) and the arm that
    did not (module).

This script keeps only `typedef <atom-keyword> <name>;` -- no dimensions, so the
canonical kind really is PredefinedIntegerType / StringType / FloatingType /
CHandleType / EventType -- in files a SystemVerilog front end would read, and
reports the ENCLOSING SCOPE KIND by a brace/keyword walk (module, interface,
package, class, program, $unit).

  usage: atomtd.py <root> [root ...]
"""
import os
import re
import sys
from collections import Counter

ATOM = r'(?:int\s+unsigned|int|byte|shortint|longint|integer|time|string|real|shortreal|chandle|event)'
# `typedef <atom> <name>;` and nothing else -- a trailing `[` makes it an ARRAY
# typedef and a different canonical kind.
TD = re.compile(r'^\s*typedef\s+(' + ATOM + r')\s+([A-Za-z_]\w*)\s*;')
OPEN = re.compile(r'^\s*(?:(\w+)\s*:\s*)?(module|interface|package|class|program|checker)\b')
CLOSE = re.compile(r'^\s*end(module|interface|package|class|program|checker)\b')
SV_EXT = ('.sv', '.svh', '.v', '.vh')


def scan(path):
    hits = []
    stack = []
    try:
        with open(path, 'r', errors='replace') as f:
            for line in f:
                # strip line comments so a commented-out typedef is not counted
                line = line.split('//')[0]
                c = CLOSE.match(line)
                if c:
                    if stack:
                        stack.pop()
                    continue
                o = OPEN.match(line)
                if o:
                    # CORRECTED BY THE PASS-44 VERIFIER. The old guard was
                    # `if not line.rstrip().endswith(';')`, meant to skip a
                    # forward `typedef class foo;`. It ALSO refused to push
                    # `package p;`, `module m;` and `module m(...);` — every one
                    # of which ends in ';' — so EVERY package- and module-scope
                    # hit landed in the $unit bucket and the census reported
                    # "0 at module scope" for a shape that has 8 such
                    # declarations. Only a typedef/extern line is a non-opener;
                    # a bare `class foo;` IS an opener.
                    head = line.split('//')[0].strip()
                    if not (head.startswith('typedef') or
                            head.startswith('extern')):
                        stack.append(o.group(2))
                    continue
                m = TD.match(line)
                if m:
                    hits.append((stack[-1] if stack else '$unit', m.group(1),
                                 m.group(2)))
    except OSError:
        pass
    return hits


def main():
    per_scope = Counter()
    files = set()
    rows = []
    for root in sys.argv[1:]:
        for dirpath, _dirs, names in os.walk(root):
            for n in names:
                if not n.endswith(SV_EXT):
                    continue
                p = os.path.join(dirpath, n)
                h = scan(p)
                if h:
                    files.add(p)
                for scope, kw, name in h:
                    per_scope[scope] += 1
                    rows.append((scope, kw, name, p))
    print('files with at least one SCALAR atom typedef: %d' % len(files))
    for scope, n in sorted(per_scope.items(), key=lambda kv: -kv[1]):
        print('  scope %-10s %d' % (scope, n))
    print()
    for scope, kw, name, p in sorted(rows):
        print('%-10s typedef %-14s %-24s %s' % (scope, kw, name, p))


if __name__ == '__main__':
    main()
