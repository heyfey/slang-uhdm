#!/usr/bin/env python3
"""r11u29repro/nettype_census.py — which nets carry vpiNetType, golden vs ours.

CALIBRATION FIRST (RESUME.md 9): run it golden-vs-golden and the two columns
must agree on every row.  The census is DEPTH-KEYED by the dump's own
indentation, so a net inside an elaborated instance is a different row from the
same-named net in the module DEFINITION — the two producers label the DEF/ELAB
view differently and a slot-keyed census would be blind below the slot.

usage: nettype_census.py <dump>           -> `<netType?> <indent> <name>` lines
       nettype_census.py <dumpA> <dumpB>  -> only the rows that DISAGREE
"""
import re
import sys

NET = re.compile(r'^(\s*)\\_([a-z_0-9]*net[a-z_0-9]*): \(([^)]*)\)')


def census(path):
    """A `|vpiNetType:` line belongs to the NEAREST PRECEDING object line whose
    indent is exactly two less — the dump indents an object's own fields by two
    past the `\\_<kind>:` line.  Keying off a running "current object" instead
    loses the field to whatever nested subtree the dump printed in between
    (`vpiTypespec` -> `ref_typespec` -> ...), which is how this census read a
    stamped net as unset the first time it was written."""
    rows = {}
    stack = {}          # indent -> key of the object opened at that indent
    for ln in open(path, errors='replace'):
        raw = ln.rstrip('\n')
        stripped = raw.lstrip()
        ind = len(raw) - len(stripped)
        if stripped.startswith('\\_'):
            for k in [k for k in stack if k >= ind]:
                del stack[k]
            m = NET.match(raw)
            if m:
                key = (ind, m.group(2), m.group(3))
                stack[ind] = key
                rows.setdefault(key, False)
            else:
                stack[ind] = None
            continue
        if stripped.startswith('|vpiNetType'):
            owner = stack.get(ind - 2)
            if owner is not None:
                rows[owner] = True
    return rows


def main():
    a = census(sys.argv[1])
    if len(sys.argv) == 2:
        for k in sorted(a):
            print('%s %3d %-10s %s' % ('NETTYPE' if a[k] else 'unset---',
                                       k[0], k[1], k[2]))
        return
    b = census(sys.argv[2])
    keys = sorted(set(a) | set(b))
    ndis = 0
    for k in keys:
        va, vb = a.get(k), b.get(k)
        if va != vb:
            ndis += 1
            print('DISAGREE golden=%-8s ours=%-8s %3d %-10s %s' % (
                va, vb, k[0], k[1], k[2]))
    print('-- rows golden=%d ours=%d disagree=%d' % (len(a), len(b), ndis))


if __name__ == '__main__':
    main()
