#!/usr/bin/env python3
"""r10uvm63 CELL EXTRACTOR — the INDEX TYPESPEC of an associative array, on BOTH
sides, listed at OWN CHILD DEPTH.

    usage: ct63cells.py <arm.sv> <g.dump> <o.dump>
           ct63cells.py <arm.sv> <g.dump>            # golden alone

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours — the same order as
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.  Column order here never varies.

WHAT IT MEASURES, and why each step is the way it is:

  * IT DESCENDS TO THE INDEX POSITION, it does not grep a kind.  Two positions
    exist and they are DIFFERENT SLOTS, so they are collected separately and
    labelled:
      OUTER — `array_typespec` -> `vpiIndexTypespec` -> `ref_typespec` ->
              `vpiActual` -> THE TYPESPEC.
      INNER — the marker range's `STRING:associative` constant ->
              `vpiTypespec` -> `ref_typespec` -> `vpiActual` -> THE TYPESPEC
              (`emitAssocDims`'s second call site; dimensions 2..N).
    A law that holds in one slot and not the other would be invisible to a
    kind-grep and is the reason arm b3 exists.

  * IT THEN RE-FINDS THAT TYPESPEC AT ITS FULLEST OCCURRENCE.  A campaign law:
    AN OBJECT IS NOT A DUMP OCCURRENCE — the same object prints at several
    depths and `uhdm-dump` prints only the header when it re-prints a
    back-reference.  Under `vpiActual` the index typespec ALWAYS prints as a
    bare header, so reading the fields there would report EVERY cell as empty on
    BOTH sides — a perfect-looking, perfectly wrong table.  The fields are read
    at the occurrence with the most own-child rows, which for a typespec is the
    top-level typespec LISTING.  `occ=` is the number of occurrences of the
    header text, so a genuine span collision is VISIBLE rather than silently
    merged.

  * OWN CHILD DEPTH ONLY.  An object's fields are the lines at (header indent +
    2); anything deeper belongs to a child object and is never folded into a
    field column.  `vpiParent` is reported as PRESENT/absent (its target is the
    next row at the field's own indent) because that is the field the
    § arrayElemTsSignedParented9 twin stamps and this pass must decide about.

  * A CELL WHERE ONE SIDE EMITS NO OBJECT PRINTS `-NOOBJ-`, NOT `-`.  Those are
    different readings: an absent FIELD and an absent OBJECT.  The summary
    counts UNMEASURED separately from DIFFER, and a `-NOOBJ-` can never be
    counted as agreement.

  * THE CELL NAME COMES FROM THE ARM SOURCE, not from the dump: the index
    typespec is spanned inside the `[...]` selector, so its LINE is the
    declaration's line and the declarator name on that line is the cell id.
    One declaration per line is what makes this exact.
"""
import re
import sys


def parse(path):
    """[(indent, kind, text)] where kind is 'O' (object), 'F' (field), 'X'."""
    out = []
    with open(path, errors='replace') as f:
        for raw in f:
            line = raw.rstrip('\n')
            stripped = line.lstrip(' ')
            indent = len(line) - len(stripped)
            if stripped.startswith('\\_'):
                out.append((indent, 'O', stripped[2:]))
            elif stripped.startswith('|'):
                out.append((indent, 'F', stripped[1:]))
            else:
                out.append((indent, 'X', stripped))
    return out


def children(rows, i):
    """Own-child-depth rows of the object at row i: indent == indent(i)+2."""
    base = rows[i][0]
    want = base + 2
    kids = []
    j = i + 1
    while j < len(rows):
        ind = rows[j][0]
        if ind <= base:
            break
        if ind == want:
            kids.append((j, rows[j][1], rows[j][2]))
        j += 1
    return kids


def field_object(rows, i, fieldname):
    """The object a `|<field>:` edge points at: the next row at the SAME indent
    as the field line, which uhdm-dump prints immediately after it."""
    for (j, kind, text) in children(rows, i):
        if kind == 'F' and text.rstrip(':') == fieldname:
            if (j + 1 < len(rows) and rows[j + 1][0] == rows[j][0]
                    and rows[j + 1][1] == 'O'):
                return j + 1
    return None


HDR = re.compile(r'^(\w+):\s*(\([^)]*\))?\s*(.*)$')


def hdr_parts(text):
    """(kind, name, tail) of an object header line."""
    m = HDR.match(text)
    if not m:
        return (text, '', '')
    return (m.group(1), (m.group(2) or '').strip('()'), m.group(3).strip(', '))


def span_of(tail):
    """`line:20:19, endln:20:26` -> `20:19-20:26`; '' when unspanned."""
    a = re.search(r'line:(\d+):(\d+)', tail)
    b = re.search(r'endln:(\d+):(\d+)', tail)
    if not a:
        return ''
    s = f'{a.group(1)}:{a.group(2)}'
    if b:
        s += f'-{b.group(1)}:{b.group(2)}'
    return s


def collect_index_ts(rows):
    """[(slot, kind, span, header_text)] for every INDEX-position typespec.

    slot is 'OUTER' (vpiIndexTypespec) or 'INNER' (assoc marker constant)."""
    found = []
    for i, (ind, k, text) in enumerate(rows):
        if k != 'O':
            continue
        kind, _name, _tail = hdr_parts(text)
        slot = None
        if kind == 'array_typespec':
            rt = field_object(rows, i, 'vpiIndexTypespec')
            slot = 'OUTER'
        elif kind == 'constant':
            # the assoc marker: a STRING:associative constant carrying a
            # vpiTypespec.  Its OWN fields include `STRING:associative`.
            if not any(kk == 'F' and t.startswith('STRING:associative')
                       for (_j, kk, t) in children(rows, i)):
                continue
            rt = field_object(rows, i, 'vpiTypespec')
            slot = 'INNER'
        else:
            continue
        if rt is None:
            continue
        if hdr_parts(rows[rt][2])[0] != 'ref_typespec':
            continue
        ts = field_object(rows, rt, 'vpiActual')
        if ts is None:
            continue
        tk, _tn, ttail = hdr_parts(rows[ts][2])
        found.append((slot, tk, span_of(ttail), rows[ts][2]))
    return found


def fullest(rows, header_text):
    """Row index of the occurrence of `header_text` with the most own-child
    rows, and the number of occurrences."""
    best, bestn, occ = None, -1, 0
    for i, (_ind, k, text) in enumerate(rows):
        if k != 'O' or text != header_text:
            continue
        occ += 1
        n = len(children(rows, i))
        if n > bestn:
            best, bestn = i, n
    return best, occ


def fields_of(rows, i):
    """{fieldname: value} at own child depth, plus PARENT presence."""
    out = {}
    for (_j, k, text) in children(rows, i):
        if k != 'F':
            continue
        if ':' in text:
            n, v = text.split(':', 1)
        else:
            n, v = text, ''
        out[n] = v.rstrip(':')
    return out


def cellnames(svpath):
    """line number -> declarator name, read from the arm source."""
    names = {}
    with open(svpath, errors='replace') as f:
        for n, line in enumerate(f, 1):
            m = re.match(r'\s*\w[\w\s\[\]:\$]*?\b([cmfg]\d\d_\w+)\s*\[', line)
            if m:
                names[n] = m.group(1)
    return names


def side(svpath, dumppath):
    rows = parse(dumppath)
    names = cellnames(svpath)
    cells = {}
    for (slot, tk, span, hdr) in collect_index_ts(rows):
        ln = int(span.split(':')[0]) if span else 0
        nm = names.get(ln, f'?line{ln}')
        key = (nm, slot, span)
        i, occ = fullest(rows, hdr)
        f = fields_of(rows, i) if i is not None else None
        cells[key] = (tk, f, occ)
    return cells


def show(f, key):
    if f is None:
        return '-NOOBJ-'
    return f.get(key, '-')


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    sv, gd = sys.argv[1], sys.argv[2]
    od = sys.argv[3] if len(sys.argv) > 3 else None
    G = side(sv, gd)
    O = side(sv, od) if od else {}
    keys = sorted(set(G) | set(O),
                  key=lambda k: (k[0], k[1],
                                 tuple(int(x) for x in
                                       re.findall(r'\d+', k[2])) or (0,)))
    hdr = (f'{"CELL":<18}{"SLOT":<6}{"SPAN":<14}'
           f'{"G kind":<20}{"G signed":<9}{"G parent":<9}'
           f'{"O kind":<20}{"O signed":<9}{"O parent":<9}VERDICT')
    print(hdr)
    print('-' * len(hdr))
    same = differ = unmeasured = 0
    for k in keys:
        gk, gf, gocc = G.get(k, (None, None, 0))
        ok, of, oocc = O.get(k, (None, None, 0))
        gs = show(gf, 'vpiSigned') if gk else '-NOOBJ-'
        os_ = show(of, 'vpiSigned') if ok else '-NOOBJ-'
        gp = ('yes' if (gf and 'vpiParent' in gf) else
              ('-NOOBJ-' if not gk else 'no'))
        op = ('yes' if (of and 'vpiParent' in of) else
              ('-NOOBJ-' if not ok else 'no'))
        if not od:
            v = ''
        elif gk is None or ok is None:
            v = 'UNMEASURED'
            unmeasured += 1
        elif (gk, gs, gp) == (ok, os_, op):
            v = 'same'
            same += 1
        else:
            v = 'DIFFER'
            differ += 1
        occ = f'  [gocc={gocc} oocc={oocc}]' if (gocc > 1 or oocc > 1) else ''
        print(f'{k[0]:<18}{k[1]:<6}{k[2]:<14}'
              f'{(gk or "-NOOBJ-"):<20}{gs:<9}{gp:<9}'
              f'{(ok or "-NOOBJ-"):<20}{os_:<9}{op:<9}{v}{occ}')
    if od:
        print(f'-- cells={len(keys)} same={same} DIFFER={differ} '
              f'UNMEASURED={unmeasured}')
    else:
        print(f'-- GOLDEN ONLY, cells={len(keys)}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
