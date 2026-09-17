#!/usr/bin/env python3
"""r11u62 SHAPE LISTER + keyed census for THE OVERRIDE ACTUAL'S OWN ENCODING.

ENCODING-AWARE (the r11u61 lesson): every row prints vpiConstType AND the FULL
value string AND the decompile -- never a bare count, never a truncation.

  shape62.py --shape <dump.raw>              the shape listing of one database
  shape62.py --rows  <lhs.raw> [<rhs.raw>]   every param_assign Rhs, full text
  shape62.py <lhs.raw> <rhs.raw> <tag>       the keyed census (LHS is golden)

The census key is (owner kind, typespec kind, vpiSize, value tag, constType) --
the five fields `constant::Compare` turns on for this family.  Calibrate
golden-vs-golden FIRST: it must print LINES 0.
"""
import sys
import collections

sys.path.insert(0, __file__.rsplit('/', 1)[0])
from cenc50 import objects, tsname


def paRows(path):
    """Every param_assign's Rhs, keyed by the Lhs parameter's full name."""
    out = collections.defaultdict(list)
    for d in objects(path):
        if d['_kind'] != 'param_assign':
            continue
        lhs, rhs = d.get('child:vpiLhs'), d.get('child:vpiRhs')
        if lhs is None or rhs is None:
            continue
        h = lhs.get('_hdr', '')
        fn = h[h.find('(') + 1:h.find(')')] if '(' in h and ')' in h else ''
        fn = fn.strip() or (lhs.get('vpiFullName', '') or '').strip()
        if not fn:
            continue
        if rhs['_kind'] != 'constant':
            out[fn].append(('<%s>' % rhs['_kind'], '', '', '', ''))
        else:
            out[fn].append((
                rhs.get('_valtag', '-'),
                (rhs.get('_val', '-') or '-').strip(),
                rhs.get('vpiSize', '-').strip(),
                rhs.get('vpiConstType', '-').strip(),
                (rhs.get('vpiDecompile', '-') or '-').strip(),
                tsname(rhs)))
    return {k: tuple(v) for k, v in out.items()}


def fmt(r):
    if len(r) == 5:
        return r[0]
    return 'tag=%-4s ct=%-2s size=%-4s val=%s dec=%s ts=%s' % (
        r[0], r[3], r[2], r[1], r[4], r[5])


def rowsMain(argv):
    a = paRows(argv[0])
    b = paRows(argv[1]) if len(argv) > 1 else None
    same = diff = 0
    for k in sorted(set(a) | (set(b) if b else set())):
        if b is None:
            for r in a.get(k, ()):
                print('ROW  %-34s %s' % (k, fmt(r)))
            continue
        if a.get(k) == b.get(k):
            same += 1
            for r in a.get(k, ()):
                print('SAME %-34s %s' % (k, fmt(r)))
        else:
            diff += 1
            for r in a.get(k, ()):
                print('DIFF %-34s G= %s' % (k, fmt(r)))
            for r in b.get(k, ()):
                print('     %-34s O= %s' % ('', fmt(r)))
    if b is not None:
        print('ROWS %d SAME %d DIFF %d' % (len(set(a) | set(b)), same, diff))


def shapes(path):
    """The SHAPE LISTER: every constant keyed by the census key, with a
    representative FULL value and decompile printed beside the count."""
    cnt = collections.Counter()
    rep = {}
    for d in objects(path):
        if d['_kind'] != 'constant':
            continue
        own = d.get('_owner')
        key = (own['_kind'] if own else '-', tsname(d),
               d.get('vpiSize', '-').strip(),
               d.get('_valtag', '-'), d.get('vpiConstType', '-').strip())
        cnt[key] += 1
        rep.setdefault(key, ((d.get('_val', '-') or '-').strip(),
                             (d.get('vpiDecompile', '-') or '-').strip()))
    for k in sorted(cnt):
        v, dec = rep[k]
        print('SHAPE n=%-5d owner=%-20s ts=%-20s size=%-5s tag=%-5s ct=%-3s '
              'val=%s dec=%s' % (cnt[k], k[0], k[1], k[2], k[3], k[4], v, dec))
    print('SHAPES %d  constants %d' % (len(cnt), sum(cnt.values())))


def census(lhs, rhs, tag):
    def keyed(path):
        cnt = collections.Counter()
        rep = {}
        for d in objects(path):
            if d['_kind'] != 'constant':
                continue
            own = d.get('_owner')
            key = (own['_kind'] if own else '-', tsname(d),
                   d.get('vpiSize', '-').strip(), d.get('_valtag', '-'),
                   d.get('vpiConstType', '-').strip())
            cnt[key] += 1
            rep.setdefault(key, ((d.get('_val', '-') or '-').strip(),
                                 (d.get('vpiDecompile', '-') or '-').strip()))
        return cnt, rep
    ca, ra = keyed(lhs)
    cb, rb = keyed(rhs)
    lines = 0
    for k in sorted(set(ca) | set(cb)):
        if ca.get(k, 0) == cb.get(k, 0):
            continue
        lines += 1
        v, dec = ra.get(k, rb.get(k, ('-', '-')))
        print('%s DIFF lhs=%-4d rhs=%-4d owner=%-20s ts=%-20s size=%-5s '
              'tag=%-5s ct=%-3s val=%s dec=%s'
              % (tag, ca.get(k, 0), cb.get(k, 0), k[0], k[1], k[2], k[3],
                 k[4], v, dec))
    print('%s LINES %d  lhs_const %d  rhs_const %d'
          % (tag, lines, sum(ca.values()), sum(cb.values())))


def main():
    a = sys.argv[1:]
    if not a:
        print(__doc__)
        return
    if a[0] == '--shape':
        shapes(a[1])
    elif a[0] == '--rows':
        rowsMain(a[1:])
    else:
        census(a[0], a[1], a[2] if len(a) > 2 else 'X')


main()
