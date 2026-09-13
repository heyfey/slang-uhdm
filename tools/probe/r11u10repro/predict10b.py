#!/usr/bin/env python3
"""r11u10 — the SECOND half of the a-priori mover prediction.

`predict10.py` only reads `param_assign` Rhs nodes, so it cannot see the
CONNECTION road (`ModuleEmit.cpp:11083`), which mints the same flattened
`op75` as a port high_conn.  This scanner finds EVERY `operation op75` whose
typespec actual is an `array_typespec` and whose operand vector is LEAF-ONLY
(no nested operation, no tagged_pattern) with two or more operands — the exact
object § unpackedStructArrPatOneElemFold stops minting — wherever it sits.

Usage: predict10b.py <workdir>/<mode> [...]
"""
import os
import subprocess
import sys

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'


def ind(l):
    return len(l) - len(l.lstrip(' '))


def extent(lines, lo, hi):
    b = ind(lines[lo])
    k = lo + 1
    while k < hi:
        if lines[k].strip() and ind(lines[k]) <= b:
            break
        k += 1
    return k


def members(lines, lo, hi):
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
            if ':' in st:
                k, v = st[1:].split(':', 1)
                fields[k] = v
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


def scan(path):
    out = subprocess.run([DUMP, path], capture_output=True, text=True,
                         errors='replace')
    lines = out.stdout.split('\n')
    hits = []
    for i, l in enumerate(lines):
        s = l.strip()
        if not s.startswith('\\_operation:'):
            continue
        e = extent(lines, i, len(lines))
        f, kids = members(lines, i, e)
        if f.get('vpiOpType') != '75':
            continue
        ts = [k for k in kids if k[0] == 'vpiTypespec']
        if not ts:
            continue
        act = [c for c in members(lines, ts[0][1], ts[0][2])[1]
               if c[0] == 'vpiActual']
        if not act:
            continue
        if not lines[act[0][1]].strip().lstrip('\\_').startswith(
                'array_typespec'):
            continue
        ops = [k for k in kids if k[0] == 'vpiOperand']
        if len(ops) < 2:
            continue
        kinds = {lines[c[1]].strip().split(':')[0].lstrip('\\_') for c in ops}
        if kinds & {'operation', 'tagged_pattern'}:
            continue
        hits.append((len(ops), s.split(', ', 1)[-1]))
    return hits


def main():
    rows = {}
    for moded in sys.argv[1:]:
        for d in sorted(os.listdir(moded)):
            p = os.path.join(moded, d, 'slang.uhdm')
            if not os.path.isfile(p):
                continue
            h = scan(p)
            if h:
                rows.setdefault(d.rsplit('-', 1)[0], []).extend(h)
    for r in sorted(rows):
        print('FLAT-ARRAY-OP %-32s n=%d  %s' %
              (r, len(rows[r]), sorted({x[0] for x in rows[r]})))
    print('rows=%d' % len(rows))


main()
