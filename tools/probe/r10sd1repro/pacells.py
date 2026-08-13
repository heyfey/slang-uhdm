#!/usr/bin/env python3
"""r10sd1 — list every `class_typespec` FULL print in a dump together with
(a) whether it carries vpiParameter/vpiParamAssign, (b) its vpiParent kind+name,
(c) its vpiClassDefn.

The (P,A) grid (cells.py) says WHICH cells differ; this says WHAT ELSE is true
of them, which is how the discriminator is found instead of guessed.  A rule
that fires on "class-scope class-handle typedef" would fire on ~40 objects
golden leaves bare, so the population of PA-carrying objects in GOLDEN is the
thing to read first.

    usage: pacells.py <dump> [--only-pa]
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_([a-z_0-9]+): ?(.*)$')
LBL = re.compile(r'^(\s*)\|([A-Za-z0-9_]+):')


def main():
    path = sys.argv[1]
    only = '--only-pa' in sys.argv
    lines = open(path, errors='replace').read().split('\n')
    n = len(lines)
    i = 0
    rows = []
    while i < n:
        om = OBJ.match(lines[i])
        if om and om.group(2) == 'class_typespec':
            ind = len(om.group(1))
            body = om.group(3)
            nm = re.match(r'^\(([^)]*)\)', body)
            name = nm.group(1) if nm else ''
            sm = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', body)
            span = '%s:%s-%s:%s' % sm.groups() if sm else '-'
            labels = []
            par = ''
            cd = ''
            j = i + 1
            while j < n:
                lm = LBL.match(lines[j])
                om2 = OBJ.match(lines[j])
                cur = len(lm.group(1)) if lm else (len(om2.group(1)) if om2 else -1)
                if cur < 0 or cur <= ind:
                    break
                if lm and cur == ind + 2:
                    labels.append(lm.group(2))
                    if lm.group(2) in ('vpiParent', 'vpiClassDefn') and j + 1 < n:
                        o3 = OBJ.match(lines[j + 1])
                        if o3:
                            n3 = re.match(r'^(?:\(([^)]*)\)|[^(]*\(([^)]*)\))',
                                          o3.group(3))
                            txt = '%s(%s)' % (o3.group(2),
                                              (n3.group(1) or n3.group(2)) if n3 else '')
                            if lm.group(2) == 'vpiParent':
                                par = txt
                            else:
                                cd = txt
                j += 1
            if j > i + 1:
                pa = ('P' if 'vpiParameter' in labels else '-') + \
                     ('A' if 'vpiParamAssign' in labels else '-')
                if not only or pa != '--':
                    rows.append((pa, name, span, par, cd))
            i = j
            continue
        i += 1
    for pa, name, span, par, cd in rows:
        print('%s  %-42s %-22s parent=%-46s cd=%s' % (pa, name[:42], span, par[:46], cd))
    print('--- %d full prints listed' % len(rows))


main()
