#!/usr/bin/env python3
"""r11u24 L1 — the SOURCE-keyed a-priori mover prediction.

Nothing in a database records that a const function wrote a NESTED struct
member; the shape lives only in the sources.  L1 is deliberately a SUPERSET:
every test directory holding a file in which some line inside a `function` body
assigns to a selector chain of DEPTH >= 2 off a local
(`<id>.<id>.<id> = ...` or `<id>.<id>[...] = ...`).

    predL1_24.py <corpus-root> [<corpus-root> ...]
"""
import os, re, sys

# `a.b.c = ` / `a.b[0] = ` / `a[0].b = `, not `==`, not a compare
ASG = re.compile(r'^\s*([A-Za-z_]\w*)((?:\s*\.\s*[A-Za-z_]\w*|\s*\[[^\];]*\])'
                 r'{2,})\s*(?:<?=)(?!=)')
FUNC = re.compile(r'\bfunction\b')
ENDF = re.compile(r'\bendfunction\b')
EXTS = ('.sv', '.v', '.svh', '.vh')


def scan(path):
    hits = []
    try:
        lines = open(path, errors='replace').read().split('\n')
    except OSError:
        return hits
    depth = 0
    for i, l in enumerate(lines):
        if FUNC.search(l):
            depth += 1
        if depth > 0:
            m = ASG.match(l)
            if m:
                hits.append((i + 1, l.strip()[:110]))
        if ENDF.search(l) and depth > 0:
            depth -= 1
    return hits


def main(roots):
    for root in roots:
        root = os.path.abspath(root)
        for d in sorted(os.listdir(root)):
            dp = os.path.join(root, d)
            if not os.path.isdir(dp):
                continue
            found = []
            for dirpath, _dirs, files in os.walk(dp):
                for f in files:
                    if f.endswith(EXTS):
                        for ln, txt in scan(os.path.join(dirpath, f)):
                            found.append('%s:%d: %s' %
                                         (os.path.relpath(
                                             os.path.join(dirpath, f), dp),
                                          ln, txt))
            if found:
                print('%s  <- %d' % (d, len(found)))
                for f in found[:6]:
                    print('      ' + f)


if __name__ == '__main__':
    main(sys.argv[1:])
