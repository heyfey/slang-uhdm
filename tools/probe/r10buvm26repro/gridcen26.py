#!/usr/bin/env python3
"""r10buvm26 — per-LINE object census of a `uhdm-dump`, as a MULTISET.

MEASUREMENT ONLY; the official `uhdm-cmp` is the judge.  LHS is ALWAYS golden.

For every object the dump lists (following every slot EXCEPT the `vpiParent`
back-reference, which re-prints an ancestor) this emits one row

    <line> <kind> <vpiName> <slot-under-parent> <parent-kind>

so a cell can be compared as a MULTISET rather than through a last-writer
dict — keys collide by construction here (a `.sv` line holds many objects) and
a dict would silently drop rows (RESUME.md §9, "census traps").

The serializer's `weaklyReferenced` leftover listing is EXCLUDED (see
`asgcen26.parse`): no Compare walk reaches it, so a difference there is not a
difference the judge can see.

`vpiFullName` is reported only under `--full`: no generated `Compare` reads it,
so it is byte-identity evidence and never a verdict.
"""
import collections
import re
import sys

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from asgcen26 import parse, LOC        # noqa: E402


def rows(path, full, weak=False):
    out = []

    def walk(n, slot, pkind):
        ln = n.loc.split(':')[0] if n.loc else '-'
        nm = n.attrs.get('vpiName', '')
        r = '%s %s %s %s %s' % (ln, n.kind, nm, slot, pkind)
        if full:
            r += ' ' + n.attrs.get('vpiFullName', '')
        out.append(r)
        for lab, lst in n.kids.items():
            if lab == 'vpiParent':
                continue
            for k in lst:
                walk(k, lab, n.kind)

    for root in parse(path, weak):
        walk(root, 'ROOT', '-')
    return out


def main():
    a, b = sys.argv[1], sys.argv[2]
    full = '--full' in sys.argv
    only = None
    for x in sys.argv[3:]:
        if x.startswith('--lines='):
            only = set(x.split('=', 1)[1].split(','))
    ca = collections.Counter(rows(a, full))
    cb = collections.Counter(rows(b, full))
    lines = sorted({r.split(' ', 1)[0] for r in list(ca) + list(cb)},
                   key=lambda x: (x == '-', int(x) if x.isdigit() else 0))
    same = diff = 0
    for ln in lines:
        if only and ln not in only:
            continue
        la = collections.Counter({k: v for k, v in ca.items()
                                  if k.split(' ', 1)[0] == ln})
        lb = collections.Counter({k: v for k, v in cb.items()
                                  if k.split(' ', 1)[0] == ln})
        if la == lb:
            same += 1
            continue
        diff += 1
        print('=== line %s' % ln)
        for k, v in sorted((la - lb).items()):
            print('  GOLDEN-ONLY x%d  %s' % (v, k))
        for k, v in sorted((lb - la).items()):
            print('  OURS-ONLY   x%d  %s' % (v, k))
    print('LINES same=%d differ=%d' % (same, diff))


if __name__ == '__main__':
    main()
