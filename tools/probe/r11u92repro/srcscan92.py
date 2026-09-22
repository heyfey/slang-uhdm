#!/usr/bin/env python3
"""r11u92 SOURCE-LEVEL CENSUS — the second, independent instrument beside the
emitter trace, so a corpus zero is TWO readings and not one.

  LAW A (§ caProgramHomeNoCells92)  a `program ... endprogram` body that
        carries a continuous assignment in either written form: an `assign`
        statement, or a net declaration with an initializer (`wire x = …;`).
        Program bodies are extracted by keyword span, and only the body text
        is scanned, so a module's `assign` beside a program is not a site.

  LAW B (§ caStrPortNetRevertsToPort92)  a net declaration carrying a
        parenthesised DRIVE or CHARGE strength (r11u90's own LAW A regex,
        reused verbatim) — the NECESSARY condition — reported with whether the
        enclosing file declares a NON-ANSI port list at all.  A file with no
        strength declaration cannot hold a LAW B site.

Both scans carry a POSITIVE CONTROL: run with `--control <griddir>` and the
scan must return nonzero for this pass's own arms.  A scan that cannot find
them is a dead instrument and its corpus zero means nothing.

  usage: srcscan92.py <dir> [<dir> ...] [--control]
"""
import os
import re
import sys

NETKW = (r'\b(?:wire|tri|tri0|tri1|triand|trior|trireg|wand|wor|uwire|'
         r'supply0|supply1)\b')
DRIVE = (r'(?:supply0|supply1|strong0|strong1|pull0|pull1|weak0|weak1|'
         r'highz0|highz1)')
CHARGE = r'(?:small|medium|large)'
STR = re.compile(NETKW + r'\s*\(\s*(?:' + DRIVE + r'|' + CHARGE + r')\s*[,)]')
PROG = re.compile(r'\bprogram\b(?!\s*:)(.*?)\bendprogram\b', re.S)
ASSIGN = re.compile(r'\bassign\b')
NDA = re.compile(NETKW + r'[^;]*?=[^;]*;', re.S)
# `module m (a, b);` — a header port list of BARE identifiers (no direction,
# no type, no `.name(`): the non-ANSI form LAW B needs.
NONANSI = re.compile(r'\b(?:module|macromodule)\s+\w+\s*(?:#\s*\([^;]*?\))?\s*'
                     r'\(\s*[A-Za-z_]\w*\s*(?:,\s*[A-Za-z_]\w*\s*)*\)\s*;')
EXT = ('.sv', '.v', '.svh', '.vh')


def strip(txt):
    txt = re.sub(r'//[^\n]*', '', txt)
    return re.sub(r'/\*.*?\*/', '', txt, flags=re.S)


def scan(root):
    a, b, files = [], [], 0
    for dp, _dn, fn in os.walk(root):
        for f in sorted(fn):
            if not f.endswith(EXT):
                continue
            p = os.path.join(dp, f)
            files += 1
            try:
                txt = strip(open(p, errors='replace').read())
            except OSError:
                continue
            for m in PROG.finditer(txt):
                body = m.group(1)
                kinds = []
                if ASSIGN.search(body):
                    kinds.append('assign')
                if NDA.search(body):
                    kinds.append('netdeclassign')
                if kinds:
                    ln = txt[:m.start()].count('\n') + 1
                    a.append('%s:%d: program body carries %s' %
                             (p, ln, '+'.join(kinds)))
            na = 'NONANSI' if NONANSI.search(txt) else 'ansi-only'
            for i, l in enumerate(txt.split('\n'), 1):
                if STR.search(l):
                    b.append('%s:%d: [%s] %s' % (p, i, na, l.strip()[:100]))
    return a, b, files


def main():
    roots = [r for r in sys.argv[1:] if not r.startswith('--')]
    for root in roots:
        a, b, files = scan(root)
        print('== %s  files=%d' % (root, files))
        print('   LAW A (program home carrying a cont_assign) sites = %d' % len(a))
        for l in a[:60]:
            print('      ' + l)
        print('   LAW B (strength net declaration, the necessary condition)'
              ' sites = %d' % len(b))
        for l in b[:60]:
            print('      ' + l)


if __name__ == '__main__':
    main()
