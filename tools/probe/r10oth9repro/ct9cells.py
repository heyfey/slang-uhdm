#!/usr/bin/env python3
"""r10oth9 CELL EXTRACTOR — the ELEMENT TYPESPEC of a named array variable, on
BOTH sides, listed at OWN CHILD DEPTH.

    usage: ct9cells.py <g.dump> <o.dump> [cell-name-prefix-regex]

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours — the same order as
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.  Column order here never varies.

WHAT IT MEASURES, and why each step is the way it is:

  * IT DESCENDS, it does not grep.  For a variable named NAME it finds the
    variable object, follows `vpiReg` to the ELEMENT var when there is one (a
    plain scalar has none and is measured through its own `vpiTypespec`, which
    is what makes the control cell and the target cell one table), then
    `vpiTypespec` -> `ref_typespec` -> `vpiActual` -> THE TYPESPEC.  Grepping a
    typespec by span would silently pick up any other object sharing the line.

  * IT THEN RE-FINDS THAT TYPESPEC AT ITS FULLEST OCCURRENCE.  A campaign law:
    AN OBJECT IS NOT A DUMP OCCURRENCE — the same object prints at several
    depths and `uhdm-dump` prints only the header when it re-prints a
    back-reference.  The fields therefore have to be read at the occurrence with
    the most children, which for a typespec is the top-level typespec LISTING.
    `occ=` in the output is the number of occurrences of that header text, so a
    genuine span collision is VISIBLE rather than silently merged.

  * OWN CHILD DEPTH ONLY.  An object's fields are the lines at (header indent +
    2).  Anything deeper belongs to a child object and is reported separately
    (`nested` is never mixed into a field column).

  * A CELL WHERE ONE SIDE EMITS NO OBJECT PRINTS `-NOOBJ-`, NOT `-`.  That is a
    louder reading than an absent field and the two must not be confused: the
    verdict column says UNMEASURED for it, and the summary counts UNMEASURED
    separately from DIFFER.
"""
import re
import sys


def parse(path):
    """[(indent, kind, text)] where kind is 'O' (object) or 'F' (field)."""
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
    """The object a `|<fieldname>:` edge points at: the next row at the SAME
    indent as the field line, which uhdm-dump prints immediately after it."""
    for (j, kind, text) in children(rows, i):
        if kind == 'F' and text.rstrip(':') == fieldname:
            if j + 1 < len(rows) and rows[j + 1][0] == rows[j][0] and rows[j + 1][1] == 'O':
                return j + 1
    return None


def own_field(rows, i, fieldname):
    for (_j, kind, text) in children(rows, i):
        if kind == 'F' and text.startswith(fieldname + ':'):
            return text.split(':', 1)[1]
    return None


HDR = re.compile(r'^(?P<type>[a-z_0-9]+):\s*(?P<rest>.*)$')


def hdr_type(text):
    m = HDR.match(text)
    return m.group('type') if m else text


def hdr_name(text):
    m = re.match(r'^[a-z_0-9]+:\s*\((?P<n>[^)]*)\)', text)
    return m.group('n') if m else ''


def hdr_span(text):
    m = re.search(r'line:(\d+:\d+), endln:(\d+:\d+)', text)
    return '%s-%s' % (m.group(1), m.group(2)) if m else ''


def find_var(rows, name):
    """Every occurrence of a *_var / io_decl object whose name ends in `name`,
    richest first (most own-depth children)."""
    hits = []
    for i, (ind, kind, text) in enumerate(rows):
        if kind != 'O':
            continue
        t = hdr_type(text)
        if not (t.endswith('_var') or t == 'io_decl'):
            continue
        n = hdr_name(text)
        if not n:
            continue
        leaf = re.split(r'::|\.', n)[-1]
        if leaf == name:
            hits.append((len(children(rows, i)), i))
    hits.sort(reverse=True)
    return [i for (_c, i) in hits]


def richest_occurrence(rows, header):
    """The occurrence of an object with this exact header text that has the most
    own-depth children, plus the total occurrence count."""
    occ = [(len(children(rows, i)), i)
           for i, (_ind, kind, text) in enumerate(rows)
           if kind == 'O' and text == header]
    if not occ:
        return None, 0
    occ.sort(reverse=True)
    return occ[0][1], len(occ)


def cell(rows, name):
    """(dict) the measurement for one cell on one side."""
    r = {'var': None, 'varsigned': None, 'elem': None, 'elemsigned': None,
         'ts': None, 'tsspan': None, 'tsparent': None, 'tssigned': None,
         'occ': 0, 'nested': 0, 'fields': ''}
    vis = find_var(rows, name)
    if not vis:
        return r
    vi = vis[0]
    r['var'] = hdr_type(rows[vi][2])
    r['varsigned'] = own_field(rows, vi, 'vpiSigned')
    holder = vi
    reg = field_object(rows, vi, 'vpiReg')
    if reg is not None:
        r['elem'] = hdr_type(rows[reg][2])
        r['elemsigned'] = own_field(rows, reg, 'vpiSigned')
        holder = reg
    rt = field_object(rows, holder, 'vpiTypespec')
    if rt is None:
        return r
    ts = field_object(rows, rt, 'vpiActual')
    if ts is None:
        return r
    header = rows[ts][2]
    best, occ = richest_occurrence(rows, header)
    r['ts'] = hdr_type(header)
    r['tsspan'] = hdr_span(header)
    r['occ'] = occ
    kids = children(rows, best)
    r['fields'] = ' '.join(t for (_j, k, t) in kids if k == 'F')
    r['tssigned'] = own_field(rows, best, 'vpiSigned')
    p = field_object(rows, best, 'vpiParent')
    if p is not None:
        pn = hdr_name(rows[p][2])
        r['tsparent'] = hdr_type(rows[p][2]) + (('(' + pn + ')') if pn else '')
    # nested = rows strictly deeper than own child depth, reported separately
    base = rows[best][0]
    j = best + 1
    n = 0
    while j < len(rows) and rows[j][0] > base:
        if rows[j][0] > base + 2:
            n += 1
        j += 1
    r['nested'] = n
    return r


def show(v):
    return v if v is not None else '-'


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    g = parse(sys.argv[1])
    o = parse(sys.argv[2])
    pat = re.compile(sys.argv[3] if len(sys.argv) > 3 else r'^[a-z]\d\d_')
    names = []
    for rows in (g, o):
        for (_i, kind, text) in ((i, k, t) for i, (_d, k, t) in enumerate(rows)):
            n = hdr_name(text)
            if not n:
                continue
            leaf = re.split(r'::|\.', n)[-1]
            if pat.match(leaf) and leaf not in names:
                names.append(leaf)
    names.sort()
    print('%-22s %-14s %-12s %-30s %-6s | %-14s %-12s %-30s %-6s | %s' % (
        'CELL', 'G:ts', 'G:tsSigned', 'G:tsParent', 'G:av', 'O:ts',
        'O:tsSigned', 'O:tsParent', 'O:av', 'VERDICT'))
    ndiff = nunmeas = nagree = nkind = 0
    for n in names:
        cg = cell(g, n)
        co = cell(o, n)
        if cg['ts'] is None or co['ts'] is None:
            verdict = 'UNMEASURED'
            nunmeas += 1
        elif cg['ts'] != co['ts']:
            # A DIFFERENT typespec CLASS is not a field disagreement and must
            # not be scored as one: f06/g06 (`typedef byte barr_t[]`) is golden
            # `array_typespec` against our `byte_typespec`, and both carry the
            # same (absent) vpiSigned/vpiParent -- comparing only the two fields
            # would score that cell EQ, which is a FALSE agreement.
            verdict = 'DIFFER-KIND'
            nkind += 1
        elif (show(cg['tssigned']) == show(co['tssigned']) and
              show(cg['tsparent']) == show(co['tsparent'])):
            verdict = 'EQ'
            nagree += 1
        else:
            bits = []
            if show(cg['tssigned']) != show(co['tssigned']):
                bits.append('SIGNED')
            if show(cg['tsparent']) != show(co['tsparent']):
                bits.append('PARENT')
            verdict = 'DIFFER-' + '+'.join(bits)
            ndiff += 1
        print('%-22s %-14s %-12s %-30s %-6s | %-14s %-12s %-30s %-6s | %s' % (
            n,
            cg['ts'] or '-NOOBJ-', show(cg['tssigned']), show(cg['tsparent']),
            show(cg['varsigned']),
            co['ts'] or '-NOOBJ-', show(co['tssigned']), show(co['tsparent']),
            show(co['varsigned']),
            verdict))
    print('CELLS=%d EQ=%d DIFFER=%d DIFFERKIND=%d '
          'UNMEASURED(one side emits no object)=%d'
          % (len(names), nagree, ndiff, nkind, nunmeas))


if __name__ == '__main__':
    main()
