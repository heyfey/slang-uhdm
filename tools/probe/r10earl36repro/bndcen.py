#!/usr/bin/env python3
"""r10earl36 — the RANGE-BOUND census.

For every SOURCE LINE of an arm file, records the MULTISET of range-bound LEAF
objects (`constant` / `ref_obj`) that a uhdm-dump prints at that line, together
with the fields that decide the head: the constant's value / size / constType
and the span of the int_typespec its ref_typespec points at (which names WHICH
parameter Surelog resolved — the whole point of this pass' grid).

Instrument notes, paid for by r10earl35's refutation F5:
  * uhdm-dump prints ONE object at several depths (once in place, again under
    every back-reference), so INDENT IS NOT IDENTITY.  Indent is used only to
    find an object's own attribute lines and is then folded out of the key; the
    per-key counts are MULTISET counts over the whole dump.
  * uhdm-dump's FIRST LINE is the database path -> the caller must `sed 1d`.
  * A cell with no bound leaf at all prints as `-` rather than being omitted, so
    "the grid ran and found nothing" cannot be confused with "the cell is
    absent".
"""
import re
import sys
from collections import Counter

OBJ = re.compile(r'^(\s*)\\_(\w+): *(\([^)]*\))?,? *(.*)$')
ATTR = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def parse(path):
    """-> {srcline: Counter(render)}"""
    out = {}
    lines = open(path, 'rt', errors='replace').read().split('\n')
    i = 0
    n = len(lines)
    while i < n:
        m = OBJ.match(lines[i])
        if not m:
            i += 1
            continue
        indent, kind, name, tail = m.group(1), m.group(2), m.group(3), m.group(4)
        if kind not in ('constant', 'ref_obj'):
            i += 1
            continue
        lm = LOC.search(tail)
        if not lm:
            i += 1
            continue
        sl, sc, el, ec = (int(x) for x in lm.groups())
        # own attributes: the lines that follow at indent+2, stopping at the
        # first line whose indent is <= this object's.
        want = len(indent) + 2
        fields = {}
        tsline = None
        j = i + 1
        while j < n:
            am = ATTR.match(lines[j])
            om = OBJ.match(lines[j])
            ind = None
            if am:
                ind = len(am.group(1))
            elif om:
                ind = len(om.group(1))
            if ind is None or ind < want:
                break
            if am and ind == want:
                key = am.group(2)
                val = am.group(3)
                if key in ('vpiDecompile', 'vpiSize', 'vpiConstType', 'vpiName',
                           'UINT', 'INT', 'HEX', 'BIN', 'OCT', 'DEC'):
                    fields[key] = val
                if key == 'vpiTypespec':
                    fields['ts'] = '?'
            # the actual typespec the ref_typespec points at
            if om and 'typespec' in om.group(2) and om.group(2) != 'ref_typespec':
                tl = LOC.search(om.group(4) or '')
                if tl and tsline is None and 'ts' in fields:
                    tsline = '%s@%s:%s' % (om.group(2), tl.group(1), tl.group(2))
            j += 1
        val = None
        for k in ('UINT', 'INT', 'HEX', 'BIN', 'OCT', 'DEC'):
            if k in fields:
                val = '%s:%s' % (k, fields[k])
                break
        if kind == 'ref_obj':
            r = 'ref_obj(%s)' % fields.get('vpiName', '')
        else:
            r = 'const[%s sz%s ct%s]' % (val, fields.get('vpiSize', '-'),
                                         fields.get('vpiConstType', '-'))
            if tsline:
                r += '->' + tsline
            elif 'ts' in fields:
                r += '->ts?'
        r += ' @%d:%d-%d:%d' % (sl, sc, el, ec)
        out.setdefault(sl, Counter())[r] += 1
        i += 1
    return out


def render(c):
    if not c:
        return '-'
    return '  '.join('%s x%d' % (k, v) for k, v in sorted(c.items()))


def main():
    if len(sys.argv) < 3:
        sys.exit('usage: bndcen.py <dump> <cellmap: line=name,...> [dump2 ...]')
    cells = {}
    for tok in sys.argv[2].split(','):
        if not tok:
            continue
        ln, nm = tok.split('=')
        cells[int(ln)] = nm
    dumps = [sys.argv[1]] + sys.argv[3:]
    parsed = [parse(d) for d in dumps]
    for ln in sorted(cells):
        print('CELL %-14s line %-4d' % (cells[ln], ln))
        for d, p in zip(dumps, parsed):
            print('   %-10s %s' % (d, render(p.get(ln))))


if __name__ == '__main__':
    main()
