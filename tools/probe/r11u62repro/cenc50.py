#!/usr/bin/env python3
"""r11u50 — the CONSTANT-ENCODING census.

One row per `constant:` object in a `uhdm-dump`, keyed by the pair the C7 head
turns on: (owner kind, the typespec it REFERS TO through its ref_typespec,
vpiSize, value tag, vpiConstType).  Golden-vs-golden FIRST (`CALIB`): a zero
line count there is the only licence to read a golden-vs-ours count as a
difference.

usage: cenc50.py <lhs.raw> <rhs.raw> [label]        # the keyed join
       cenc50.py --shape <raw>                      # THE SHAPE LISTER
       cenc50.py --rows <raw> [ctfilter]            # one line per constant
"""
import re, sys, collections

KIND = re.compile(r'^(\s*)(?:\\_)?([a-z_0-9]+): ')
HDRLINE = re.compile(r'line:(\d+):')
FIELD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
VALTAG = re.compile(r'^(\s*)\|(INT|UINT|BIN|HEX|OCT|DEC|STRING|REAL|SCALAR|TIME):(.*)$')


def objects(path):
    """Every object in dump order, each a dict with '_kind', its own '|field:'
    values, 'child:<field>' -> the child object dict, and '_owner'."""
    at = {}            # field-indent -> the object whose fields live there
    out = []
    pend = {}          # field-indent -> the last field name seen there
    for ln in open(path, errors='replace'):
        ln = ln.rstrip('\n')
        mv = VALTAG.match(ln)
        if mv:
            o = at.get(len(mv.group(1)))
            if o is not None:
                o['_valtag'] = mv.group(2)
                o['_val'] = mv.group(3)
            continue
        mf = FIELD.match(ln)
        if mf:
            ind = len(mf.group(1))
            o = at.get(ind)
            if o is not None:
                o[mf.group(2)] = mf.group(3)
            pend[ind] = mf.group(2)
            continue
        mk = KIND.match(ln)
        if mk:
            ind = len(mk.group(1))
            d = {'_kind': mk.group(2), '_indent': ind, '_hdr': ln}
            ml = HDRLINE.search(ln)
            if ml:
                d['_line'] = ml.group(1)
            owner = at.get(ind)
            d['_owner'] = owner
            if owner is not None and pend.get(ind):
                owner.setdefault('child:' + pend[ind], d)
            at[ind + 2] = d
            if ind == 0 and owner is None:
                at[0] = d          # the ROOT design keeps its fields at 0
            out.append(d)
            continue
    return out


def tsname(c):
    """The TYPE a constant refers to: its ref_typespec's vpiActual kind."""
    rt = c.get('child:vpiTypespec')
    if rt is None:
        return 'NONE'
    a = rt.get('child:vpiActual')
    return a['_kind'] if a else 'ref?'


def const_rows(path):
    rows = []
    for d in objects(path):
        if d['_kind'] != 'constant':
            continue
        own = d.get('_owner')
        rows.append((own['_kind'] if own else '-',
                     tsname(d),
                     d.get('vpiSize', '-').strip(),
                     d.get('_valtag', '-'),
                     d.get('vpiConstType', '-').strip()))
    return rows


def census(path):
    c = collections.Counter()
    for r in const_rows(path):
        c[r] += 1
    return c


def main():
    if sys.argv[1] == '--shape':
        c = census(sys.argv[2])
        for k in sorted(c, key=lambda k: (-c[k], k)):
            print('SHAPE %6d  owner=%-22s ts=%-20s size=%-5s tag=%-7s ct=%s' %
                  (c[k], k[0], k[1], k[2], k[3], k[4]))
        print('SHAPES %d  CONSTANTS %d' % (len(c), sum(c.values())))
        return
    if sys.argv[1] == '--rows':
        want = sys.argv[3] if len(sys.argv) > 3 else None
        for r in const_rows(sys.argv[2]):
            if want and r[4] != want:
                continue
            print('ROW owner=%-22s ts=%-20s size=%-5s tag=%-7s ct=%s' % r)
        return
    lhs, rhs = census(sys.argv[1]), census(sys.argv[2])
    label = sys.argv[3] if len(sys.argv) > 3 else ''
    n = 0
    for k in sorted(set(lhs) | set(rhs)):
        if lhs[k] == rhs[k]:
            continue
        n += 1
        print('%s DIFF lhs=%-4d rhs=%-4d owner=%-22s ts=%-20s size=%-5s tag=%-7s ct=%s'
              % (label, lhs[k], rhs[k], k[0], k[1], k[2], k[3], k[4]))
    print('%s LINES %d  lhs_const %d  rhs_const %d' %
          (label, n, sum(lhs.values()), sum(rhs.values())))


if __name__ == '__main__':
    main()
