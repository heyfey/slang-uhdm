#!/usr/bin/env python3
"""Cross-tabulate RETURN-NAME reference bindings, golden vs ours.

Input: two r10uvm28g census files (golden, ours).
A census line is
    <VIEW> <tf-fullname> | <kind> '<name>' <line>:<col> -> <actual> @ <ctx>
A RETURN-NAME reference is one whose name equals the LAST '::'/'.' segment of
the owning routine's fullname.  The key is (view, tf, kind, name, line:col) --
position is NOT part of the key so a parent-shape change shows as a cell move
rather than as an add+drop.
"""
import re
import sys
from collections import defaultdict

LINE = re.compile(r"^(\S+) (\S+) \| (\S+) '([^']*)' (\d+:\d+) -> (.*) @ (.*)$")


def load(path):
    rows = {}
    for ln in open(path):
        m = LINE.match(ln.rstrip('\n'))
        if not m:
            continue
        view, tf, kind, name, pos, act, ctx = m.groups()
        rows[(view, tf, kind, name, pos)] = (act, ctx)
    return rows


def lastseg(tf):
    for sep in ('::', '.'):
        pass
    s = tf
    for sep in ('::', '.'):
        if sep in s:
            s = s.split(sep)[-1]
    return s


def isret(key):
    view, tf, kind, name, pos = key
    return name and name == lastseg(tf)


g = load(sys.argv[1])
o = load(sys.argv[2])
gk = set(k for k in g if isret(k))
ok = set(k for k in o if isret(k))
print('return-name refs: golden %d  ours %d  shared %d  golden-only %d  ours-only %d'
      % (len(gk), len(ok), len(gk & ok), len(gk - ok), len(ok - gk)))

# cell = (view, first ctx element of OURS, bound-ness pair)
cells = defaultdict(lambda: defaultdict(int))
detail = defaultdict(list)
for k in sorted(gk | ok):
    ga = g.get(k, (None, None))
    oa = o.get(k, (None, None))
    gb = 'x' if ga[0] in (None, '-') else 'B'
    ob = 'x' if oa[0] in (None, '-') else 'B'
    ctx = (oa[1] or ga[1] or '?').split('/')[0]
    view = k[0]
    cells[(view, ctx)][gb + ob] += 1
    if gb != ob:
        detail[(view, ctx, gb + ob)].append(k)

print()
print('%-10s %-26s %6s %6s %6s %6s' % ('VIEW', 'PARENT-KIND', 'gB oB', 'gB ox',
                                       'gx oB', 'gx ox'))
tot = defaultdict(int)
for (view, ctx) in sorted(cells):
    c = cells[(view, ctx)]
    print('%-10s %-26s %6d %6d %6d %6d' % (view, ctx, c['BB'], c['Bx'],
                                           c['xB'], c['xx']))
    for kk in ('BB', 'Bx', 'xB', 'xx'):
        tot[kk] += c[kk]
print('%-10s %-26s %6d %6d %6d %6d' % ('TOTAL', '', tot['BB'], tot['Bx'],
                                       tot['xB'], tot['xx']))
print('DIFFERING CELLS (gB ox + gx oB) = %d' % (tot['Bx'] + tot['xB']))

if len(sys.argv) > 3 and sys.argv[3] == '-v':
    print()
    for kk in sorted(detail):
        print('--- %s (%d)' % (kk, len(detail[kk])))
        for k in detail[kk][:40]:
            print('    ', k, 'g=', g.get(k), 'o=', o.get(k))
