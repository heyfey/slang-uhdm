#!/usr/bin/env python3
"""r10uvm68 VERIFIER — THE FULL PER-OBJECT SIGNEDNESS JOIN, not just the NAMED
population.

The implementer's counterexample hunt (`ct68ctrex.sh`) asks only: "does any
golden variable with a NAMED typespec carry vpiSigned?".  That bounds the
DIRECTION the patch removes flags in, but it says nothing about the ANON
bucket — and golden's own SimpleUVM table has 380 `int_var ANON:int_typespec
signed=-` objects, i.e. golden ALSO omits the flag on a large population whose
typespec is anonymous.  If we stamp any of those, the pass's law is incomplete
in a way its instruments cannot see.

So: join EVERY variable object in the two dumps on (kind, fullname, span) and
report the four cells of the signedness contingency table, per kind.

  usage: r68v_overstamp.py <golden.dump> <ours.dump> [--show KIND] [--max N]
"""
import re
import sys
import collections

OBJ = re.compile(r'^(\s*)\\_(\w+): ?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
NAM = re.compile(r'^(?:\S+ )?\(([^)]*)\)')
VAR = re.compile(r'_var$|^io_decl$')


def side(path):
    objs = {}
    stack = []
    with open(path, errors='replace') as fh:
        for raw in fh:
            raw = raw.rstrip('\n')
            m = OBJ.match(raw)
            if m:
                col = len(m.group(1))
                kind, rest = m.group(2), m.group(3)
                while stack and stack[-1][0] >= col:
                    stack.pop()
                ml = LOC.search(rest)
                mn = NAM.match(rest)
                key = (kind, mn.group(1) if mn else '',
                       '%s:%s-%s:%s' % ml.groups() if ml else '')
                stack.append((col, key))
                if VAR.search(kind):
                    objs.setdefault(key, {'s': '-', 'f': 0})
                continue
            m = FLD.match(raw)
            if m:
                col = len(m.group(1))
                while stack and stack[-1][0] >= col:
                    stack.pop()
                if not stack:
                    continue
                k = stack[-1][1]
                if k in objs:
                    objs[k]['f'] += 1
                    if m.group(2) == 'vpiSigned' and m.group(3):
                        objs[k]['s'] = m.group(3)
    return {k: v['s'] for k, v in objs.items() if v['f']}


def main():
    a = sys.argv[1:]
    show = a[a.index('--show') + 1] if '--show' in a else None
    mx = int(a[a.index('--max') + 1]) if '--max' in a else 25
    g, o = side(a[0]), side(a[1])
    tab = collections.defaultdict(collections.Counter)
    over = []
    under = []
    for k in set(g) & set(o):
        cell = (g[k], o[k])
        tab[k[0]][cell] += 1
        if g[k] == '-' and o[k] != '-':
            over.append(k)
        elif g[k] != '-' and o[k] == '-':
            under.append(k)
    print('LHS=GOLDEN %s  RHS=OURS %s' % (a[0], a[1]))
    print('joined on (kind, fullname, span); objects in BOTH dumps only')
    print('%-18s %8s %8s %8s %8s %10s %10s'
          % ('kind', 'G-/O-', 'G1/O1', 'G-/O1', 'G1/O-', 'GOLDONLY', 'OURSONLY'))
    for kd in sorted(tab):
        c = tab[kd]
        go = sum(1 for k in g if k[0] == kd) - sum(c.values())
        oo = sum(1 for k in o if k[0] == kd) - sum(c.values())
        print('%-18s %8d %8d %8d %8d %10d %10d'
              % (kd, c[('-', '-')], c[('1', '1')], c[('-', '1')],
                 c[('1', '-')], go, oo))
    print('---- OVER-STAMP (golden omits, we emit): %d objects' % len(over))
    print('---- UNDER-STAMP (golden emits, we omit): %d objects' % len(under))
    if show:
        for lst, lab in ((over, 'OVER'), (under, 'UNDER')):
            rows = [k for k in lst if k[0] == show]
            print('== %s, kind=%s (%d)' % (lab, show, len(rows)))
            for k in sorted(rows)[:mx]:
                print('   %-16s %-70s @%s' % k)


main()
