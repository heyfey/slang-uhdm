#!/usr/bin/env python3
"""r11u29repro/decode_heads.py — ID-BLIND decode of an official uhdm-cmp head.

INPUT  : the .cmp files rowheads.sh wrote (one per row x mode).
OUTPUT : one CSV line per row — the head's FACE, normalised so two rows whose
         head is the same producer fact collide on one key.

WHY ID-BLIND: object ids and source line/col are per-design; a cluster claim
needs the SHAPE (owner kind, field, the other side's kind chain), never the
id.  Names are kept in a SEPARATE column: they are evidence for the decode,
never part of the key.

THE FACE GRAMMAR (uhdm-cmp prints, per §9 of RESUME.md):
  LHS:                      -- golden is ALWAYS the LHS
  decompile:                -- printed TWICE per side for ONE head
  <kind>: (<name>), id:N    -- the head OBJECT
  |<field>:                 -- the field chain the head hangs on
  \\_<kind>: (<name>), id:N  -- the field's value
  RHS: <null>               -- SINGULAR overload, value missing on OUR side
  RHS: <object>             -- both sides present, the payload differs

The head's SIDE-FACE is therefore (lhs kind, the field chain, rhs kind) and the
RHS-null-ness.  That tuple is the cluster key.
"""
import re
import sys
import os
import csv

OBJ = re.compile(r'^(\\_)?([a-z_0-9]+): (\(([^)]*)\))?,? *id:(\d+)')


def strip_ids(line):
    line = re.sub(r'id:\d+', 'id:#', line)
    line = re.sub(r'line:\d+:\d+', 'line:#', line)
    line = re.sub(r'endln:\d+:\d+', 'endln:#', line)
    line = re.sub(r'col:\d+', 'col:#', line)
    return line.rstrip()


def parse(path):
    txt = open(path, errors='replace').read().splitlines()
    if not txt:
        return None
    # the head block: everything from the first 'LHS:' to the 'RHS:' line
    try:
        i = txt.index('LHS:')
    except ValueError:
        return None
    rhs_i = None
    for j in range(i + 1, len(txt)):
        if txt[j].startswith('RHS:'):
            rhs_i = j
            break
    lhs_block = txt[i + 1:rhs_i] if rhs_i is not None else txt[i + 1:]
    rhs_line = txt[rhs_i] if rhs_i is not None else ''
    rhs_block = txt[rhs_i:] if rhs_i is not None else []

    def first_obj(block):
        for ln in block:
            m = OBJ.match(ln)
            if m and not ln.startswith('\\_'):
                return m.group(2), (m.group(4) or '')
        return '', ''

    lhs_kind, lhs_name = first_obj(lhs_block)
    # the field chain: the |field: lines of the FIRST decompile only
    fields = []
    seen_second = 0
    for ln in lhs_block:
        if ln.startswith('decompile:'):
            seen_second += 1
            if seen_second > 1:
                break
            continue
        if ln.startswith('|') and ln.endswith(':'):
            fields.append(ln[1:-1])
        elif ln.startswith('\\_'):
            m = OBJ.match(ln)
            if m and fields:
                fields[-1] = fields[-1] + '->' + m.group(2)
    rhs_null = rhs_line.strip() == 'RHS: <null>'
    if rhs_null:
        rhs_kind, rhs_name = '<null>', ''
    else:
        rhs_kind, rhs_name = first_obj(rhs_block[1:])
        if not rhs_kind:
            m = OBJ.match(rhs_line[4:].strip())
            rhs_kind = m.group(2) if m else rhs_line[4:].strip()[:40]
    face = '%s|%s|%s' % (lhs_kind, ','.join(fields), rhs_kind)
    return dict(lhs_kind=lhs_kind, lhs_name=lhs_name, fields=','.join(fields),
                rhs_kind=rhs_kind, rhs_name=rhs_name, face=face,
                head_text='\n'.join(strip_ids(l) for l in txt[i:min(len(txt), (rhs_i or len(txt)) + 12)]))


def main():
    outw = csv.writer(sys.stdout)
    outw.writerow(['row', 'mode', 'cmplines', 'lhs_kind', 'fieldchain',
                   'rhs_kind', 'lhs_name', 'rhs_name', 'face'])
    for path in sorted(sys.argv[1:]):
        base = os.path.basename(path)
        if not base.endswith('.cmp'):
            continue
        stem = base[:-4]
        row, mode = stem.rsplit('.', 1)
        n = sum(1 for _ in open(path, errors='replace'))
        d = parse(path)
        if d is None:
            outw.writerow([row, mode, n, 'EQUAL', '', '', '', '', 'EQUAL'])
            continue
        outw.writerow([row, mode, n, d['lhs_kind'], d['fields'], d['rhs_kind'],
                       d['lhs_name'], d['rhs_name'], d['face']])


if __name__ == '__main__':
    main()
