#!/usr/bin/env python3
"""r11u26 L1 — the SOURCE-keyed a-priori mover prediction, a deliberate
SUPERSET of L2.

The face is a const-function body writing a struct member from a WHOLE READ OF
A NAME: `<local>.<member>[.<member>...] = <identifier>;` inside a `function`
body.  L1 reads the SOURCES, so it also sees designs whose databases never made
it (a SLANG_REJECT row has no `slang.uhdm` for L2 to read).

    predL1_26.py <corpus-root> [<corpus-root> ...]

Prints one HIT per test directory and a final census line.
"""
import os, re, sys

# `a.b = c;` / `a.b.c = d;`  — a selector chain on the left, a BARE identifier
# (possibly `pkg::NAME`) on the right.  Not `==`, not a compare, no call, no
# operator on the right.
ASG = re.compile(r'^\s*([A-Za-z_]\w*)((?:\s*\.\s*[A-Za-z_]\w*)+)\s*(?:<?=)(?!=)'
                 r'\s*((?:[A-Za-z_]\w*\s*::\s*)?[A-Za-z_]\w*)\s*;')
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
                hits.append('%s%s<-%s' % (m.group(1), m.group(2).replace(' ', ''),
                                          m.group(3).replace(' ', '')))
        if ENDF.search(l):
            depth = max(0, depth - 1)
    return hits


def main(roots):
    total = flagged = 0
    for root in roots:
        for d in sorted(os.listdir(root)):
            p = os.path.join(root, d)
            if not os.path.isdir(p):
                continue
            total += 1
            hits = []
            for dirpath, _x, files in os.walk(p):
                for f in sorted(files):
                    if f.endswith(EXTS):
                        hits += scan(os.path.join(dirpath, f))
            if hits:
                flagged += 1
                print('HIT %s  %s' % (d, ' '.join(sorted(set(hits))[:8])))
    print('L1 dirs=%d flagged=%d' % (total, flagged))


if __name__ == '__main__':
    main(sys.argv[1:])
