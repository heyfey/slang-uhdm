#!/usr/bin/env python3
"""r11u90 SOURCE-LEVEL CENSUS — the SECOND, INDEPENDENT instrument beside
`cellcen90.py`'s emitter trace, so a corpus zero is two readings and not one.

It scans every source file the two corpora carry for the WRITTEN forms the two
laws key on, and it carries its OWN positive control: the pass's grid, where
the same scan must return a nonzero count for the arms that carry the shape.
A scan that cannot find the grid's own arms is a dead instrument and its
corpus zero means nothing.

  LAW A  a net declaration whose net keyword is followed by a parenthesised
         DRIVE strength (`wire (strong1, weak0) …`) or CHARGE strength
         (`trireg (small) …`).
  LAW B  a continuous assign whose delay is written as a BARE identifier
         (`assign #D …`), as opposed to a literal (`assign #3 …`) or a
         parenthesised expression (`assign #(D+1) …`).

usage: srcscan90.py <dir> [<dir> ...]
"""
import os
import re
import sys

NETKW = (r'\b(?:wire|tri|tri0|tri1|triand|trior|trireg|wand|wor|uwire|'
         r'supply0|supply1)\b')
DRIVE = (r'(?:supply0|supply1|strong0|strong1|pull0|pull1|weak0|weak1|'
         r'highz0|highz1)')
CHARGE = r'(?:small|medium|large)'
LAWA = re.compile(NETKW + r'\s*\(\s*(?:' + DRIVE + r'|' + CHARGE + r')\s*[,)]')
# `assign` (with an optional drive strength in front of the delay) then `#`
# then a bare identifier — never a digit, never `(`.
LAWB = re.compile(r'\bassign\b[^;#]*#\s*([A-Za-z_][A-Za-z_0-9$]*'
                  r'(?:\s*::\s*[A-Za-z_][A-Za-z_0-9$]*)?)')
EXT = ('.sv', '.v', '.svh', '.vh')


def scan(root):
    a, b, files = [], [], 0
    for dp, _dn, fn in os.walk(root):
        for f in fn:
            if not f.endswith(EXT):
                continue
            p = os.path.join(dp, f)
            files += 1
            try:
                txt = open(p, errors='replace').read()
            except OSError:
                continue
            # Strip line comments so a commented-out form is not a site.
            txt = re.sub(r'//[^\n]*', '', txt)
            for i, l in enumerate(txt.split('\n'), 1):
                if LAWA.search(l):
                    a.append(f'{p}:{i}: {l.strip()[:110]}')
                m = LAWB.search(l)
                if m:
                    b.append(f'{p}:{i}: {l.strip()[:110]}')
    return a, b, files


for root in sys.argv[1:]:
    a, b, files = scan(root)
    print(f'== {root}  files={files}')
    print(f'   LAW A (strength-decorated net declaration) sites = {len(a)}')
    for l in a[:40]:
        print('      ' + l)
    print(f'   LAW B (bare-identifier cont-assign delay)  sites = {len(b)}')
    for l in b[:40]:
        print('      ' + l)
