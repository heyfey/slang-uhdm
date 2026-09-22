#!/usr/bin/env python3
"""r11u98 SOURCE census — over-approximating scanner for the two faces.

LAWA  a module / program home that declares TWO OR MORE classes whose
      DECLARATION order differs from BYTE-LEXICOGRAPHIC NAME order.
      (That is exactly the cell the listing law moves: with one class, or
      with classes already in alphabetical order, the two orders agree and
      nothing moves.  Package and design-root homes are already name-sorted
      at the base, so they are counted separately as LAWA.pkg / LAWA.root
      calibration, not as movers.)
LAWB  a class declared inside a GENERATE region of a module / interface home
      (the class-home face), and separately a `final` construct inside a
      module's generate region.

The scanner is deliberately CRUDE and over-approximates: it is a syntactic
pre-filter whose only job is to bound where the emitter could possibly move.
THE EMITTER TRACE (cellcen98.py) IS THE AUTHORITY.

usage: srcscan98.py <dir> [<dir> ...]
"""
import os
import re
import sys

HOME_RE = re.compile(
    r'^[ \t]*(module|program|interface|package)[ \t\n]+'
    r'(?:automatic[ \t]+|static[ \t]+)?([A-Za-z_][A-Za-z0-9_$]*)', re.M)
END_RE = {'module': 'endmodule', 'program': 'endprogram',
          'interface': 'endinterface', 'package': 'endpackage'}
CLASS_RE = re.compile(
    r'^[ \t]*(?:virtual[ \t]+)?class[ \t]+'
    r'(?:automatic[ \t]+|static[ \t]+)?([A-Za-z_][A-Za-z0-9_$]*)', re.M)
ENDCLASS_RE = re.compile(r'\bendclass\b')
GEN_RE = re.compile(r'\b(generate|endgenerate)\b')
FINAL_RE = re.compile(r'^[ \t]*final\b', re.M)


def strip(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', '', t)
    return t


def homes(text):
    """yield (kind, name, body) for each top-level home, nesting-aware enough."""
    for m in HOME_RE.finditer(text):
        kind, name = m.group(1), m.group(2)
        end = END_RE[kind]
        # find the matching end keyword, skipping nested same-kind homes
        depth, pos = 1, m.end()
        pat = re.compile(r'\b(%s|%s)\b' % (kind, end))
        while depth and pos < len(text):
            mm = pat.search(text, pos)
            if not mm:
                pos = len(text)
                break
            depth += 1 if mm.group(1) == kind else -1
            pos = mm.end()
        yield kind, name, text[m.end():pos]


def own_classes(body):
    """class declarations at THIS home's own depth (not inside a nested class),
    returned as (name, offset).  Nested classes are skipped by tracking
    class/endclass depth."""
    marks = []
    for m in CLASS_RE.finditer(body):
        marks.append(('c', m.start(), m.group(1)))
    for m in ENDCLASS_RE.finditer(body):
        marks.append(('e', m.start(), None))
    marks.sort(key=lambda x: x[1])
    out, depth = [], 0
    for kind, off, nm in marks:
        if kind == 'c':
            if depth == 0:
                out.append((nm, off))
            depth += 1
        else:
            depth = max(0, depth - 1)
    return out


def gen_spans(body):
    """[(start, end)] of `generate`..`endgenerate` regions."""
    spans, depth, start = [], 0, None
    for m in GEN_RE.finditer(body):
        if m.group(1) == 'generate':
            if depth == 0:
                start = m.start()
            depth += 1
        else:
            depth -= 1
            if depth == 0 and start is not None:
                spans.append((start, m.end()))
                start = None
    return spans


def main():
    tot = {}
    for root in sys.argv[1:]:
        c = dict(lawa_mod=0, lawa_prog=0, lawa_pkg=0, lawb_class=0,
                 lawb_iface=0, lawb_final=0)
        rows = []
        for dp, _, fns in os.walk(root):
            for fn in fns:
                if not fn.endswith(('.v', '.sv', '.svh', '.vh')):
                    continue
                p = os.path.join(dp, fn)
                try:
                    text = strip(open(p, errors='replace').read())
                except OSError:
                    continue
                if 'class' not in text and 'final' not in text:
                    continue
                for kind, name, body in homes(text):
                    cls = own_classes(body)
                    gs = gen_spans(body)
                    ingen = [n for n, off in cls
                             if any(a <= off < b for a, b in gs)]
                    if kind in ('module', 'program') and len(cls) >= 2:
                        order = [n for n, _ in cls]
                        if order != sorted(order):
                            c['lawa_' + ('mod' if kind == 'module'
                                         else 'prog')] += 1
                            rows.append('LAWA %-9s %-24s %-40s %s' %
                                        (kind, name, ','.join(order), p))
                    if kind == 'package' and len(cls) >= 2:
                        order = [n for n, _ in cls]
                        if order != sorted(order):
                            c['lawa_pkg'] += 1
                            rows.append('LAWApkg %-6s %-24s %-40s %s' %
                                        (kind, name, ','.join(order), p))
                    if ingen and kind in ('module', 'program'):
                        c['lawb_class'] += 1
                        rows.append('LAWBclass %-7s %-22s %-20s %s' %
                                    (kind, name, ','.join(ingen), p))
                    if ingen and kind == 'interface':
                        c['lawb_iface'] += 1
                        rows.append('LAWBiface %-7s %-22s %-20s %s' %
                                    (kind, name, ','.join(ingen), p))
                    if kind == 'module':
                        for m in FINAL_RE.finditer(body):
                            if any(a <= m.start() < b for a, b in gs):
                                c['lawb_final'] += 1
                                rows.append('LAWBfinal %-7s %-22s %s' %
                                            (kind, name, p))
                                break
        print('%-40s %s' % (root, ' '.join('%s=%d' % kv
                                           for kv in sorted(c.items()))))
        for r in sorted(rows):
            print('    ' + r)
        tot[root] = c
    return 0


if __name__ == '__main__':
    sys.exit(main())
