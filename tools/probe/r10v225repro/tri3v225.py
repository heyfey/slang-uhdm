#!/usr/bin/env python3
"""r10v225 — the THREE-AXIS three-way score of one arm's three dumps.

  usage: tri3v225.py <golden.dump> <pristine.dump> <patched.dump> <label>

Prints one line:

  ARM <label>  ANET ...  NET ...  FIELD ...

ANET  = the array_net census, keyed (holder, name, occurrence)
NET   = the holder's own Nets() census, same key
FIELD = every field of both censuses, scored INDEPENDENTLY — a cell wrong on
        both binaries can still hide a judge-visible field that went from right
        to wrong (r10v224's R-C, one level deeper).
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import anetcen225 as A  # noqa: E402


def anet_cells(dump):
    out, holders, seen = {}, {}, {}
    for r in A.parse(dump):
        A.walk(r, holders)
    for h in sorted(holders):
        for an in holders[h]:
            full, d = A.describe(an)
            k = (h, full)
            i = seen.get(k, 0)
            seen[k] = i + 1
            out[(h, full, i)] = d
    return out


def net_cells(dump):
    out, holders, seen = {}, {}, {}

    def walk(n):
        if n.kind in A.HOLDERS:
            full = A.get(n, 'vpiFullName') or A.get(n, 'vpiName') or n.head
            lst = A.kids(n, 'vpiNet')
            if lst and (full not in holders or len(lst) > len(holders[full])):
                holders[full] = lst
        for f, c in n.children:
            if f == 'vpiParent':
                continue
            walk(c)

    for r in A.parse(dump):
        walk(r)
    for h in sorted(holders):
        for n in holders[h]:
            full = A.get(n, 'vpiFullName') or A.get(n, 'vpiName')
            k = (h, full)
            i = seen.get(k, 0)
            seen[k] = i + 1
            out[(h, full, i)] = 'nt=%s ts=%s' % (A.get(n, 'vpiNetType', '-'),
                                                 A.ts_of(n))
    return out


def fields(desc):
    out = {}
    for m in re.finditer(r'(\w+)=(\S+)', desc.split('R0[')[0]):
        out[m.group(1)] = m.group(2)
    for m in re.finditer(r'(R\d+|I\d+)\[(.*?)\]', desc):
        tag, body = m.group(1), m.group(2)
        out[tag] = body
        for part in body.split('|'):
            part = part.strip()
            lbl, _, rest = part.partition(':')
            src = rest if rest else part
            pre = '%s.%s' % (tag, lbl.strip()) if rest else tag
            for mm in re.finditer(r'(\w+)=(\S+)', src):
                out['%s.%s' % (pre, mm.group(1))] = mm.group(2)
    return out


def score(g, o1, o2):
    tg = aw = sw = sr = 0
    for k in set(g) | set(o1) | set(o2):
        gv = g.get(k)
        ok1 = (o1.get(k) == gv) if gv is not None else (k not in o1)
        ok2 = (o2.get(k) == gv) if gv is not None else (k not in o2)
        if ok1 and ok2:
            sr += 1
        elif ok2:
            tg += 1
        elif ok1:
            aw += 1
        else:
            sw += 1
    return tg, aw, sw, sr


def main():
    gd, p1, p2, label = sys.argv[1:5]
    parts = []
    fg, f1, f2 = {}, {}, {}
    for tag, get in (('ANET', anet_cells), ('NET', net_cells)):
        g, o1, o2 = get(gd), get(p1), get(p2)
        parts.append('%s TO-GOLDEN=%d AWAY=%d STILL-WRONG=%d SAME-RIGHT=%d'
                     % ((tag,) + score(g, o1, o2)))
        for k in set(g) & set(o1) & set(o2):
            for src, dst in ((g, fg), (o1, f1), (o2, f2)):
                for fn, fv in fields(src[k]).items():
                    dst[(tag, k, fn)] = fv
    parts.append('FIELD TO-GOLDEN=%d AWAY=%d STILL-WRONG=%d SAME-RIGHT=%d'
                 % score(fg, f1, f2))
    print('ARM %s  %s' % (label, '  '.join(parts)))
    for k in sorted(set(fg) | set(f1) | set(f2), key=str):
        gv = fg.get(k)
        if f1.get(k) == gv and f2.get(k) != gv:
            print('  FIELD-AWAY %s %s %s %s: G=%s PRIS=%s PAT=%s'
                  % (label, k[0], k[1][1], k[2], gv, f1.get(k), f2.get(k)))


if __name__ == '__main__':
    main()
