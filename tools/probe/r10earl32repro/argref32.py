#!/usr/bin/env python3
"""r10earl32 — WHAT the ref_obj call-arguments GOLDEN KEEPS actually bind to.

The census (census32.py) says golden keeps 234 `ref_obj` call arguments on
Earlgrey and folds 8 that we keep.  A fold law must therefore explain the
NEGATIVE side too, so this reader classifies every `ref_obj` (and every
`constant`) sitting in a `vpiArgument` slot by what its `vpiActual` names:

    parameter / var / net / port / enum_const / <none>

A `ref_obj` whose actual is a `parameter` is the cell this pass is about; every
other actual is out of the law's reach by construction and is reported so the
"golden keeps 234 refs" number cannot be waved at the law as a counterexample.

Same stub discipline as census32.py: `|vpiParent:` / `|vpiFunction:` /
`|vpiTask:` introduce back-reference STUBS and are never counted.

usage: argref32.py DUMP [--list KIND]
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_([A-Za-z_0-9]+): (.*)$')
FLD = re.compile(r'^(\s*)\|([A-Za-z_0-9]+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+)')
CALLS = ('func_call', 'task_call', 'method_func_call', 'method_task_call',
         'sys_func_call', 'sys_task_call')
STUBF = ('vpiParent', 'vpiFunction', 'vpiTask')


class N:
    __slots__ = ('type', 'field', 'sspan', 'name', 'kids', 'stub')

    def __init__(self, t, f, raw):
        self.type, self.field = t, f
        m = LOC.search(raw)
        self.sspan = '%s:%s' % (m.group(1), m.group(2)) if m else '?'
        mn = re.match(r'^\(([^)]*)\)', raw.strip())
        self.name = mn.group(1) if mn else ''
        self.kids = []
        self.stub = f in STUBF


def parse(path):
    root = N('DESIGN', '', '')
    stack = [(-2, root)]
    cf = {}
    calls = []
    with open(path, 'rt', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            m = OBJ.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                p = stack[-1][1] if stack else root
                n = N(m.group(2), cf.get(id(p), ''), m.group(3))
                p.kids.append(n)
                if n.type in CALLS and not n.stub:
                    calls.append(n)
                stack.append((ind, n))
                continue
            m = FLD.match(line)
            if m:
                ind = len(m.group(1))
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                o = stack[-1][1] if stack else root
                cf[id(o)] = m.group(2)
    return calls


def actual_of(a):
    for k in a.kids:
        if k.field == 'vpiActual':
            return k.type, k.name
    return '<none>', ''


def main():
    calls = parse(sys.argv[1])
    tab = Counter()
    rows = []
    seen = set()
    for c in calls:
        for a in c.kids:
            if a.field != 'vpiArgument':
                continue
            key = (c.type, c.name, c.sspan, a.sspan)
            if key in seen:
                continue
            seen.add(key)
            at, an = actual_of(a)
            tab[(c.type, a.type, at)] += 1
            rows.append((c.type, c.name, c.sspan, a.sspan, a.type, at, an))
    print('%-16s %-12s %-14s %s' % ('CALL KIND', 'ARG KIND', 'vpiActual', 'n'))
    for (ck, ak, at), n in sorted(tab.items(), key=lambda kv: -kv[1]):
        print('%-16s %-12s %-14s %d' % (ck, ak, at, n))
    if '--list' in sys.argv:
        want = sys.argv[sys.argv.index('--list') + 1]
        print('\n== %s ==' % want)
        for r in rows:
            if r[4] + '/' + r[5] == want or r[5] == want:
                print('  %-16s %-26s call@%-11s arg@%-11s %s -> %s %s'
                      % (r[0], r[1][:26], r[2], r[3], r[4], r[5], r[6][:40]))


if __name__ == '__main__':
    main()
