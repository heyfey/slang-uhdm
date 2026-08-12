#!/usr/bin/env python3
"""r10svs6 CELL EXTRACTOR — THE WHOLE `array_var` OBJECT of a named CLASS
PROPERTY (or module variable twin), on BOTH sides, at own child depth.

    usage: ct6cells.py <g.dump> <o.dump> [cell-name-prefix-regex]

LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours — the same order as
`uhdm-cmp <golden.uhdm> <ours.uhdm>`.  Column order here never varies.

WHY IT IS NOT r10oth9's ct9cells.py: that instrument measured ONE field pair on
the ELEMENT TYPESPEC.  This pass ADDS A WHOLE OBJECT, so the reading has to be
the object: its class, every own field golden stamps on it (`vpiSize`,
`vpiArrayType`, `vpiRandType`, `vpiVisibility`, `vpiAutomatic`, `vpiSigned`),
its `vpiRange` LIST (count and spans — a missing or extra dimension is the most
likely defect of a new emitter arm), its typespec chain
(`vpiTypespec` -> `ref_typespec` -> `vpiActual`), and its `vpiReg` ELEMENT var
with the element's own typespec chain.  A cell where one side emits NO object at
all prints `-NOOBJ-` and is counted UNMEASURED, never DIFFER: those are the
readings this pass exists to convert and they must not be diluted into the field
counts.

LAWS THIS SCRIPT ENCODES (each one a trap this campaign has paid for):
  * AN OBJECT IS NOT A DUMP OCCURRENCE.  uhdm-dump prints an object's header
    again, childless, wherever it is back-referenced.  Every reading is taken at
    the occurrence WITH THE MOST OWN-DEPTH CHILDREN, and `occ=` is reported so a
    span collision is visible instead of silently merged.
  * OWN CHILD DEPTH ONLY.  An object's fields are the lines at header-indent+2;
    anything deeper belongs to a child and is never mixed into a field column.
  * ABSENT vs ZERO.  uhdm-dump omits an int field that is 0, so `-` means the
    field is not there.  `-` and `0` are printed differently and compared as
    strings.
  * THE SPANS ARE PART OF THE READING.  A `range` at the wrong `[...]` is a
    real cmp difference (`range::Compare` reads its bounds' locations), so the
    range spans are compared, not just their count.
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


def field_objects(rows, i, fieldname):
    """Every object a `|<fieldname>:` edge points at, in order.  uhdm-dump
    prints the target immediately after the field line at the same indent."""
    out = []
    for (j, kind, text) in children(rows, i):
        if kind == 'F' and text.rstrip(':') == fieldname:
            if j + 1 < len(rows) and rows[j + 1][0] == rows[j][0] and \
               rows[j + 1][1] == 'O':
                out.append(j + 1)
    return out


def field_object(rows, i, fieldname):
    o = field_objects(rows, i, fieldname)
    return o[0] if o else None


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


def leafname(n):
    return re.split(r'::|\.', n)[-1] if n else ''


def find_var(rows, name):
    """Occurrences of a *_var object whose name leaf == name, richest first."""
    hits = []
    for i, (_ind, kind, text) in enumerate(rows):
        if kind != 'O':
            continue
        t = hdr_type(text)
        if not t.endswith('_var'):
            continue
        if leafname(hdr_name(text)) == name:
            hits.append((len(children(rows, i)), i))
    hits.sort(reverse=True)
    return [i for (_c, i) in hits]


def tschain(rows, i):
    """(ref fullname, actual kind, actual span) for an object's vpiTypespec."""
    rt = field_object(rows, i, 'vpiTypespec')
    if rt is None:
        return ('-NOTS-', '-NOTS-', '')
    fn = own_field(rows, rt, 'vpiFullName')
    ts = field_object(rows, rt, 'vpiActual')
    if ts is None:
        return (fn or '-', '-NOACTUAL-', '')
    return (fn or '-', hdr_type(rows[ts][2]) +
            (('(' + hdr_name(rows[ts][2]) + ')') if hdr_name(rows[ts][2])
             else ''), hdr_span(rows[ts][2]))


def richest_occurrence(rows, header):
    """The occurrence of an object with this exact header text carrying the most
    own-depth children (AN OBJECT IS NOT A DUMP OCCURRENCE)."""
    occ = [(len(children(rows, i)), i)
           for i, (_ind, kind, text) in enumerate(rows)
           if kind == 'O' and text == header]
    if not occ:
        return None, 0
    occ.sort(reverse=True)
    return occ[0][1], len(occ)


def cell(rows, name):
    r = {'var': None, 'span': '', 'occ': 0, 'size': None, 'atype': None,
         'rand': None, 'vis': None, 'auto': None, 'signed': None,
         'israndomized': None, 'nrng': 0, 'rngspans': '', 'tsfn': '',
         'tsact': '', 'elem': None, 'elemname': None, 'elemfn': None,
         'elemspan': '', 'elemsigned': None, 'elemtsfn': '', 'elemtsact': '',
         'elemtsspan': '', 'elemtssigned': None, 'elemtsparent': None}
    vis = find_var(rows, name)
    if not vis:
        return r
    i = vis[0]
    r['occ'] = len(vis)
    r['var'] = hdr_type(rows[i][2])
    r['span'] = hdr_span(rows[i][2])
    r['size'] = own_field(rows, i, 'vpiSize')
    r['atype'] = own_field(rows, i, 'vpiArrayType')
    r['rand'] = own_field(rows, i, 'vpiRandType')
    r['vis'] = own_field(rows, i, 'vpiVisibility')
    r['auto'] = own_field(rows, i, 'vpiAutomatic')
    r['signed'] = own_field(rows, i, 'vpiSigned')
    r['israndomized'] = own_field(rows, i, 'vpiIsRandomized')
    rngs = field_objects(rows, i, 'vpiRange')
    r['nrng'] = len(rngs)
    r['rngspans'] = ','.join(hdr_span(rows[j][2]) or '-' for j in rngs)
    r['tsfn'], r['tsact'], _sp = tschain(rows, i)
    reg = field_object(rows, i, 'vpiReg')
    if reg is not None:
        r['elem'] = hdr_type(rows[reg][2])
        r['elemname'] = own_field(rows, reg, 'vpiName')
        r['elemfn'] = own_field(rows, reg, 'vpiFullName')
        r['elemspan'] = hdr_span(rows[reg][2])
        r['elemsigned'] = own_field(rows, reg, 'vpiSigned')
        r['elemtsfn'], r['elemtsact'], r['elemtsspan'] = tschain(rows, reg)
        # § arrayElemTsSignedParented9's two fields, read at the ELEMENT
        # TYPESPEC's RICHEST occurrence -- a typespec prints childless wherever
        # it is back-referenced, and the element typespec of a shared typedef
        # prints at the top-level typespec listing, not here.
        rt = field_object(rows, reg, 'vpiTypespec')
        ts = field_object(rows, rt, 'vpiActual') if rt is not None else None
        if ts is not None:
            best, _occ = richest_occurrence(rows, rows[ts][2])
            r['elemtssigned'] = own_field(rows, best, 'vpiSigned')
            pj = field_object(rows, best, 'vpiParent')
            if pj is not None:
                pn = hdr_name(rows[pj][2])
                r['elemtsparent'] = hdr_type(rows[pj][2]) + \
                    (('(' + pn + ')') if pn else '')
    return r


def show(v):
    return v if v is not None and v != '' else '-'


# The comparison KEYS, in the order they are printed.  Every one is a field
# `variables::Compare` / `range::Compare` reads, so a disagreement in any of
# them is a real cmp difference and not cosmetics.
KEYS = ['var', 'span', 'size', 'atype', 'rand', 'israndomized', 'vis', 'auto',
        'signed', 'nrng', 'rngspans', 'tsfn', 'tsact', 'elem', 'elemname',
        'elemfn', 'elemspan', 'elemsigned', 'elemtsfn', 'elemtsact',
        'elemtsspan', 'elemtssigned', 'elemtsparent']


def enc(c):
    return ' '.join('%s=%s' % (k, show(c[k])) for k in KEYS)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    g = parse(sys.argv[1])
    o = parse(sys.argv[2])
    pat = re.compile(sys.argv[3] if len(sys.argv) > 3 else r'^[a-z]\d\d_')
    names = []
    for rows in (g, o):
        for (_d, _k, text) in rows:
            n = leafname(hdr_name(text))
            if n and pat.match(n) and n not in names:
                names.append(n)
    names.sort()
    nEQ = nDIFF = nUNM = 0
    for n in names:
        cg, co = cell(g, n), cell(o, n)
        if cg['var'] is None or co['var'] is None:
            print('%-18s UNMEASURED  G:%s  O:%s' % (
                n, 'NOOBJ' if cg['var'] is None else cg['var'],
                'NOOBJ' if co['var'] is None else co['var']))
            print('    G: %s' % (enc(cg) if cg['var'] else '-NOOBJ-'))
            print('    O: %s' % (enc(co) if co['var'] else '-NOOBJ-'))
            nUNM += 1
            continue
        diffs = [k for k in KEYS if show(cg[k]) != show(co[k])]
        if not diffs:
            print('%-18s EQ           %s' % (n, enc(cg)))
            nEQ += 1
        else:
            print('%-18s DIFFER[%s]' % (n, '+'.join(diffs)))
            print('    G: %s' % enc(cg))
            print('    O: %s' % enc(co))
            nDIFF += 1
    print('CELLS=%d EQ=%d DIFFER=%d UNMEASURED(one side emits no object)=%d'
          % (len(names), nEQ, nDIFF, nUNM))


if __name__ == '__main__':
    main()
