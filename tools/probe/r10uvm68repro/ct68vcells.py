#!/usr/bin/env python3
"""r10uvm68 VERIFIER's OWN instrument — written from the dump format, not from
ct68cells.py / dumptree.py, so a defect shared by those two cannot hide here.

Differences from the implementer's instrument, each one deliberate:

  * THE KEY CARRIES THE FILE.  uhdm-dump prints `file:<path>` on every object
    line and `dumptree.py` STRIPS IT.  Surelog synthesises `builtin.sv` in the
    arm's CWD, so every arm dump mixes TWO files, and a bare `line:col` key
    lets a builtin object and an arm object with the same span MERGE into one
    cell.  Key = (basename, kind, span).
  * "BACKREF" MEANS NO FIELDS, NOT NO CHILDREN.  `dumptree.is_backref` drops
    any object print with no CHILD OBJECT, which would also drop a real object
    that prints only scalar fields.  Here a print counts when it has ANY of its
    own `|field:` lines.
  * io_decl IS A VARIABLE-BEARING OBJECT for this pass's purposes and is
    reported, because arm a1 declares two FORMALS and the implementer's
    VARKINDS list does not contain io_decl, so those two source cells produce
    NO CELL AT ALL in its grid.

  usage: r68v_cells2.py <g.dump> <o.dump> [--kinds k1,k2] [--file BASENAME]
"""
import re
import sys
import collections

OBJ = re.compile(r'^(\s*)\\_(\w+): ?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')
FIL = re.compile(r'file:([^,]*)')
NAM = re.compile(r'^(?:\S+ )?\(([^)]*)\)')

VARKINDS = set('''int_var integer_var byte_var short_int_var long_int_var
time_var bit_var logic_var ref_var enum_var array_var packed_array_var
real_var short_real_var string_var class_var struct_var union_var chandle_var
io_decl'''.split())


def side(path, kinds, only_file=None):
    objs = {}
    stack = []          # (col, key)
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
                mf = FIL.search(rest)
                mn = NAM.match(rest)
                span = '%s:%s-%s:%s' % ml.groups() if ml else ''
                fn = (mf.group(1).rsplit('/', 1)[-1]) if mf else ''
                key = (fn, kind, span)
                stack.append((col, key))
                if kind in kinds and (only_file is None or fn == only_file):
                    e = objs.setdefault(key, {'signed': '-', 'nfld': 0,
                                              'prints': 0, 'name':
                                              mn.group(1) if mn else '',
                                              'ts': ''})
                    e['prints'] += 1
                continue
            m = FLD.match(raw)
            if m:
                col = len(m.group(1))
                while stack and stack[-1][0] >= col:
                    stack.pop()
                if not stack:
                    continue
                key = stack[-1][1]
                if key in objs:
                    objs[key]['nfld'] += 1
                    if m.group(2) == 'vpiSigned' and m.group(3):
                        objs[key]['signed'] = m.group(3)
    # a print with ZERO of its own fields anywhere is a pure back-reference
    return {k: v for k, v in objs.items() if v['nfld']}


def main():
    a = sys.argv[1:]
    kinds = VARKINDS
    onlyf = None
    if '--kinds' in a:
        kinds = set(a[a.index('--kinds') + 1].split(','))
    if '--file' in a:
        onlyf = a[a.index('--file') + 1]
    g = side(a[0], kinds, onlyf)
    o = side(a[1], kinds, onlyf)
    print('LHS=GOLDEN %s   RHS=OURS %s   KEY=(file,kind,span)' % (a[0], a[1]))
    t = collections.Counter()
    for k in sorted(set(g) | set(o)):
        x, y = g.get(k), o.get(k)
        if x is None or y is None:
            v = 'GOLDEN_ONLY' if y is None else 'OURS_ONLY'
        elif x['signed'] != y['signed']:
            v = 'DIFFER'
        else:
            v = 'EQ'
        t[v] += 1
        print('%-14s %-16s %-18s | G %-4s %-14s | O %-4s %-14s | %s'
              % (k[0], k[1], k[2],
                 x['signed'] if x else 'N/A', x['name'] if x else '',
                 y['signed'] if y else 'N/A', y['name'] if y else '', v))
    print('---- cells=%d  ' % len(set(g) | set(o))
          + '  '.join('%s=%d' % (k, t[k]) for k in sorted(t)))


main()
