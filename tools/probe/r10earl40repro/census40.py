#!/usr/bin/env python3
"""r10earl40 — THE SELECT-ON-A-PACKAGE-SCOPED-NAME CENSUS, span-keyed, BOTH SIDES.

The head's defect has a signature that a line grep CAN read, because it is a
property of ONE line: the object header of a `ref_obj` whose `vpiName` is the
ENTIRE WRITTEN TEXT of a select — it contains both `::` (package-scoped) and
`[` (a select).  Golden never writes such a name; it builds a
`var_select`/`part_select`/`bit_select` whose name is the base alone.

Two populations are counted, span-keyed so the two 4.8M-line dumps can be
joined without alignment:

  OURS   ref_obj whose vpiName matches   <...>::<...>[...]      = the defect
  GOLDEN var_select / part_select / bit_select whose vpiName contains `::`
                                                                = the target

usage: census40.py <golden.dump> <ours.dump>     (both already `sed 1d`-ed)
"""
import re
import sys
from collections import Counter

HDR = re.compile(r'^ *\\_(var_select|part_select|bit_select|'
                 r'indexed_part_select|ref_obj): *(.*?)'
                 r'(?:, )?line:(\d+):(\d+), endln:(\d+):(\d+)\s*$')
PAREN = re.compile(r'\(([^)]*)\)\s*$')


def scan(path):
    """span -> Counter of (kind, name) for select-family objects."""
    ours = Counter()   # (kind, has_colons, has_bracket) shape tally
    bysp = {}
    for ln in open(path, errors='replace'):
        m = HDR.match(ln.rstrip('\n'))
        if not m:
            continue
        kind, mid, l1, c1, l2, c2 = m.groups()
        pm = PAREN.search(mid)
        name = pm.group(1) if pm else ''
        span = '%s:%s-%s:%s' % (l1, c1, l2, c2)
        ours[(kind, '::' in name, '[' in name)] += 1
        bysp.setdefault(span, set()).add((kind, name))
    return ours, bysp


def main():
    g, gsp = scan(sys.argv[1])
    o, osp = scan(sys.argv[2])
    print('=== SHAPE TALLY  (kind, name-has-`::`, name-has-`[`)')
    print('%-24s %6s %6s %8s' % ('shape', 'golden', 'ours', 'delta'))
    for k in sorted(set(g) | set(o)):
        print('%-24s %6d %6d %+8d'
              % ('%s ::=%d [=%d' % (k[0], k[1], k[2]), g[k], o[k], o[k] - g[k]))
    print()
    # THE DEFECT POPULATION: our ref_obj whose name is a whole select text.
    print('=== OUR PASTED-TEXT ref_obj  (name has BOTH `::` and `[`)')
    bad = {sp: nm for sp, s in osp.items() for kd, nm in s
           if kd == 'ref_obj' and '::' in nm and '[' in nm}
    print('count = %d distinct spans' % len(bad))
    # What golden has AT THE SAME SPAN.
    hit = Counter()
    for sp, nm in sorted(bad.items()):
        gk = sorted({k for k, _ in gsp.get(sp, set())}) or ['<no-object>']
        hit[','.join(gk)] += 1
    print('golden object kinds at those same spans:')
    for k, v in hit.most_common():
        print('   %-30s %d' % (k, v))
    print()
    print('=== THE SPANS (first 60), with golden\'s kind+name at the span')
    for i, (sp, nm) in enumerate(sorted(bad.items())):
        if i >= 60:
            print('   ... %d more' % (len(bad) - 60))
            break
        gv = sorted(gsp.get(sp, set()))
        print('   %-18s OURS=%s' % (sp, nm))
        for kd, gn in gv:
            print('   %-18s GOLD=%s (%s)' % ('', kd, gn))


if __name__ == '__main__':
    main()
