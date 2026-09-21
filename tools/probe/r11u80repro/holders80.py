#!/usr/bin/env python3
"""r11u80 -- the HOLDER SHAPE LISTER beside the census.

One row per TOP-LEVEL signal slot in a dump section, printed as the judge
reads it: the object's KIND, the compared scalar fields it carries
(vpiSize / vpiAutomatic / vpiRandType / vpiVisibility / vpiArrayType /
vpiNetType), how many vpiRange children the holder has, and the ELEMENT
object's own kind + its actual typespec.  Never fullname, never span.

usage: holders80.py <dump> [section] [name-regex]
       holders80.py --cmp <gold.dump> <ours.dump> [section] [name-regex]
"""
import re
import sys

SECT = re.compile(r'^\|(uhdm\w+):')
TOP = re.compile(r'^  \\_(\w+): \(([^)]*)\)')
FLD = re.compile(r'^    \|(vpi\w+):(.*)$')
CHILD = re.compile(r'^    \\_(\w+): ?\(?([^),]*)')
WANT = ('vpiSize', 'vpiAutomatic', 'vpiRandType', 'vpiVisibility',
        'vpiArrayType', 'vpiNetType', 'vpiConstantVariable', 'vpiSigned')


def parse(path, section):
    lines = open(path, encoding='utf8', errors='replace').read().split('\n')
    cur_sect = None
    rows = []
    i = 0
    while i < len(lines):
        l = lines[i]
        m = SECT.match(l)
        if m:
            cur_sect = m.group(1)
            i += 1
            continue
        m = TOP.match(l)
        if m and (section is None or cur_sect == section):
            kind, name = m.group(1), m.group(2)
            flds = {}
            ranges = 0
            elem = None
            elem_ts = None
            j = i + 1
            pend = None
            while j < len(lines):
                ll = lines[j]
                if TOP.match(ll) or SECT.match(ll) or (ll and not ll.startswith('    ') and not ll.startswith('  |')):
                    break
                f = FLD.match(ll)
                if f:
                    if f.group(1) in WANT:
                        flds[f.group(1)] = f.group(2).strip()
                    pend = f.group(1)
                    j += 1
                    continue
                c = CHILD.match(ll)
                if c:
                    if pend == 'vpiRange':
                        ranges += 1
                    elif pend in ('vpiReg', 'vpiNet', 'vpiVariables',
                                  'vpiElement'):
                        elem = c.group(1)
                        # the element's actual typespec, one level down
                        k = j + 1
                        while k < len(lines) and lines[k].startswith('      '):
                            a = re.match(r'^        \\_(\w+): ?\(?([^),]*)',
                                         lines[k])
                            if a and re.match(r'^      \|vpiActual:',
                                              lines[k - 1]):
                                elem_ts = a.group(1) + (
                                    ':' + a.group(2) if a.group(2) else '')
                                break
                            k += 1
                    pend = None
                j += 1
            rows.append((cur_sect, name, kind, flds, ranges, elem, elem_ts))
            i = j
            continue
        i += 1
    return rows


def fmt(r):
    sect, name, kind, flds, ranges, elem, elem_ts = r
    f = ' '.join('%s=%s' % (k[3:], flds[k]) for k in WANT if k in flds)
    return '%-14s %-26s %-12s rng=%d %-40s elem=%s ts=%s' % (
        sect, name, kind, ranges, f, elem, elem_ts)


def key(r):
    # (section, name, KIND) — a name can own BOTH a holder and a scalar copy
    # in one section (the def/elab pair), and a dict keyed on the name alone
    # silently drops one of them (the multiset trap).
    return (r[0], r[1], r[2])


def main():
    a = sys.argv[1:]
    if a and a[0] == '--cmp':
        gold, ours = a[1], a[2]
        sect = a[3] if len(a) > 3 and a[3] != '.' else None
        rx = re.compile(a[4]) if len(a) > 4 else None
        G = {key(r): r for r in parse(gold, sect)}
        O = {key(r): r for r in parse(ours, sect)}
        for k in sorted(set(G) | set(O)):
            if rx and not rx.search(k[1]):
                continue
            g, o = G.get(k), O.get(k)
            gs = fmt(g) if g else '%-14s %-26s %-12s <NONE>' % (k[0], k[1], k[2])
            os_ = fmt(o) if o else '%-14s %-26s %-12s <NONE>' % (k[0], k[1], k[2])
            mark = '  ' if gs == os_ else '!!'
            print('%s G %s' % (mark, gs))
            print('%s O %s' % (mark, os_))
        return
    sect = a[1] if len(a) > 1 and a[1] != '.' else None
    rx = re.compile(a[2]) if len(a) > 2 else None
    for r in parse(a[0], sect):
        if rx and not rx.search(r[1]):
            continue
        print(fmt(r))


main()
