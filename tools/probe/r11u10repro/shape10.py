#!/usr/bin/env python3
"""r11u10 SHAPE LISTER — the operand TREE of a named parameter's param_assign
Rhs, per design listing, read off `uhdm-dump` text.

Usage: shape10.py <dump.txt> <ParamName> [...]        (env SHAPE_DEPTH, default 3)

Prints, per listing (allPackages / topPackages / allModules / topModules) and
per occurrence, one line per node of the Rhs tree:

    <indent><kind> op=<opType> n=<operand count> sz=<vpiSize> ...

The point of the lister is the OPERAND COUNT at every level — a vector-size
mismatch is what `uhdm-cmp` reports as a whole-vector print, so a cmp LINE
COUNT is not a distance and only the shape says what moved.
"""
import os
import re
import sys

SECT = re.compile(r'^\|uhdm(allPackages|topPackages|allModules|topModules|'
                  r'allClasses|topVars|allPrograms|allInterfaces|allUdps):')
FIELD = re.compile(r'^\|(vpiOpType|vpiSize|vpiConstType|vpiName|vpiDecompile):'
                   r'(.*)$')
VALUE = re.compile(r'^\|(UINT|INT|BIN|HEX|OCT|STRING|REAL|SCALAR):(.*)$')
CHILD_TAGS = ('vpiOperand', 'vpiPattern')


def ind(l):
    return len(l) - len(l.lstrip(' '))


def sections(lines):
    marks = [(m.group(1), i) for i, l in enumerate(lines)
             for m in [SECT.match(l)] if m]
    return [(n, i, marks[k + 1][1] if k + 1 < len(marks) else len(lines))
            for k, (n, i) in enumerate(marks)]


def extent(lines, lo, hi):
    """End index of the object block that starts at `lo`."""
    b = ind(lines[lo])
    k = lo + 1
    while k < hi:
        if lines[k].strip() and ind(lines[k]) <= b:
            break
        k += 1
    return k


def members(lines, lo, hi):
    """(fields, [(tag, childlo, childhi)]) of the object block at `lo`."""
    b = ind(lines[lo])
    fields, kids, tag = {}, [], None
    i = lo + 1
    while i < hi:
        l = lines[i]
        if not l.strip():
            i += 1
            continue
        if ind(l) <= b:
            break
        st = l.strip()
        if st.startswith('|'):
            m = FIELD.match(st)
            if m:
                fields[m.group(1)] = m.group(2)
            m = VALUE.match(st)
            if m:
                fields['val'] = m.group(1) + ':' + m.group(2)
            tag = st[1:].split(':')[0]
            i += 1
            continue
        if st.startswith('\\_'):
            e = extent(lines, i, hi)
            kids.append((tag, i, e))
            i = e
            continue
        i += 1
    return fields, kids


def walk(lines, lo, hi, depth, out, maxdepth):
    kind = lines[lo].strip().split(':')[0].lstrip('\\_')
    f, kids = members(lines, lo, hi)
    ops = [k for k in kids if k[0] in CHILD_TAGS]
    bits = ['%-14s' % kind]
    if 'vpiOpType' in f:
        bits.append('op=%s' % f['vpiOpType'])
    bits.append('n=%d' % len(ops))
    for a, b in (('vpiSize', 'sz'), ('vpiConstType', 'ct'), ('vpiName', 'nm')):
        if a in f:
            bits.append('%s=%s' % (b, f[a]))
    tsk = [k for k in kids if k[0] == 'vpiTypespec']
    if tsk:
        act = [c for c in members(lines, tsk[0][1], tsk[0][2])[1]
               if c[0] == 'vpiActual']
        if act:
            bits.append('ts=%s' % lines[act[0][1]].strip().split(':')[0]
                        .lstrip('\\_'))
            nm = lines[act[0][1]].strip()
            if '(' in nm:
                bits.append('ts_nm=%s' % nm[nm.find('('):nm.find(')') + 1])
    if 'val' in f:
        bits.append('val=%s' % f['val'])
    out.append('  ' * depth + ' '.join(bits))
    if depth < maxdepth:
        for _, clo, chi in ops:
            walk(lines, clo, chi, depth + 1, out, maxdepth)


def param_assigns(lines, lo, hi, want):
    hits = []
    for i in range(lo, hi):
        if not lines[i].lstrip().startswith('\\_param_assign:'):
            continue
        e = extent(lines, i, hi)
        _, kids = members(lines, i, e)
        lhs = [k for k in kids if k[0] == 'vpiLhs']
        rhs = [k for k in kids if k[0] == 'vpiRhs']
        if not lhs or not rhs:
            continue
        n = lines[lhs[0][1]].strip()
        tail = n[n.find('(') + 1:n.find(')')] if '(' in n else ''
        if tail.split('::')[-1].split('.')[-1] == want:
            hits.append((i, rhs[0]))
    return hits


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    with open(sys.argv[1], errors='replace') as fh:
        lines = fh.read().split('\n')
    maxdepth = int(os.environ.get('SHAPE_DEPTH', '3'))
    for name in sys.argv[2:]:
        for sect, lo, hi in sections(lines):
            for (st, (_, rlo, rhi)) in param_assigns(lines, lo, hi, name):
                out = []
                walk(lines, rlo, rhi, 0, out, maxdepth)
                print('== %s :: %s' % (sect, name))
                for l in out:
                    print('   ' + l)


main()
