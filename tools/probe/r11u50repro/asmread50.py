#!/usr/bin/env python3
"""r11u50 grid g3 reader — the ENCODING of a struct parameter's param_assign
Rhs, one row per (holder, view).

usage: asmread50.py <lhs.raw> <rhs.raw>
"""
import sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from cenc50 import objects, tsname


def rows(path):
    out = {}
    for d in objects(path):
        if d['_kind'] != 'param_assign':
            continue
        lhs = d.get('child:vpiLhs')
        rhs = d.get('child:vpiRhs')
        if lhs is None or rhs is None:
            continue
        h = lhs.get('_hdr', '')
        fn = h[h.find('(') + 1:h.find(')')] if '(' in h and ')' in h else ''
        fn = fn.strip() or (lhs.get('vpiFullName', '') or '').strip()
        if not fn:
            continue
        if rhs['_kind'] != 'constant':
            row = (rhs['_kind'],)
        else:
            row = (rhs.get('_valtag', '-'),
                   (rhs.get('_val', '-') or '-').strip()[:24],
                   rhs.get('vpiSize', '-').strip(),
                   rhs.get('vpiConstType', '-').strip(),
                   (rhs.get('vpiDecompile', '-') or '-').strip()[:24],
                   tsname(rhs))
        out.setdefault(fn, []).append(row)
    return {k: tuple(v) for k, v in out.items()}


def main():
    a, b = rows(sys.argv[1]), rows(sys.argv[2])
    same = diff = 0
    for k in sorted(set(a) | set(b)):
        if a.get(k) == b.get(k):
            same += 1
            print('SAME %-28s %s' % (k, a.get(k)))
        else:
            diff += 1
            print('DIFF %-28s G=%s' % (k, a.get(k)))
            print('     %-28s O=%s' % ('', b.get(k)))
    print('ROWS %d SAME %d DIFF %d' % (len(set(a) | set(b)), same, diff))


main()
