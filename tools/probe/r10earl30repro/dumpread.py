#!/usr/bin/env python3
"""r10earl30 — THE OWN-CHILD FIELD READER, shared by cells30.py and ctcensus.py.

MEASURE THE MEASURER.  The first version of this reader was WRONG and it very
nearly cost this pass a false over-fire report.  It scanned a constant's fields
until it met an object line, treating the object introduced by `|vpiParent:` /
`|vpiTypespec:` as a single line to skip.  But an introduced object HAS ITS OWN
CHILDREN at deeper indent:

    \\_constant: , line:59:23, endln:59:27      <- indent 4
      |vpiDecompile:1                          <- indent 6, own child
      |vpiSize:3
      |INT:1
      |vpiTypespec:
      \\_ref_typespec: (work@g1_ctx)            <- indent 6, introduced object
        |vpiParent:                            <- indent 8, NOT the constant's
        \\_constant: , line:59:23, endln:59:27
        |vpiFullName:work@g1_ctx
        |vpiActual:
        \\_int_typespec: , line:59:14, endln:59:17
      |vpiConstType:7                          <- indent 6, OWN CHILD, AFTER it

so the old reader broke out at the ref_typespec's children and reported
`vpiConstType` ABSENT for every constant that carries a typespec — which is
exactly the localparam-initializer shape.  It read golden's `vpiConstType:7`
there as "no vpiConstType", turning a correct landing into an apparent +1
over-fire.

THE FIX: an introduced object's whole SUBTREE is skipped (every following line
whose indent EXCEEDS the introduced object's), and scanning then RESUMES at the
constant's own child depth.  Scanning stops only at a line whose indent is <=
the object's own.
"""
import re

OBJ = re.compile(r'^(\s*)\\_(\w+): (.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
VKEYS = ('INT', 'UINT', 'BIN', 'HEX', 'OCT', 'DEC', 'STRING', 'REAL', 'SCAL',
         'TIME')


def indent_of(line):
    return len(line) - len(line.lstrip(' '))


def own_fields(lines, i):
    """Fields of the object whose header is lines[i], at OWN CHILD DEPTH only.

    Returns (dict of field->value, value_prefix or None).  A repeated field
    keeps its FIRST occurrence; the value line (`|INT:0`) is reported
    separately because its KEY is the encoding.
    """
    m = OBJ.match(lines[i])
    ind = len(m.group(1))
    child = ind + 2
    f, vpfx, vtxt = {}, None, None
    j = i + 1
    while j < len(lines):
        ln = lines[j]
        if not ln.strip():
            j += 1
            continue
        li = indent_of(ln)
        if li <= ind:
            break
        om = OBJ.match(ln)
        if om:
            # an INTRODUCED object at our child depth: skip its WHOLE subtree
            if li == child:
                j += 1
                while j < len(lines) and (not lines[j].strip() or
                                          indent_of(lines[j]) > child):
                    j += 1
                continue
            j += 1
            continue
        fm = FLD.match(ln)
        if fm and li == child:
            k, v = fm.group(2), fm.group(3)
            if k in VKEYS:
                if vpfx is None:
                    vpfx, vtxt = k, v
            elif k not in f:
                f[k] = v
        j += 1
    return f, vpfx, vtxt


def objects(path, kind='constant'):
    """Yield (span, name, fields, value_prefix, value_text) for each object."""
    lines = open(path, errors='replace').read().split('\n')
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m or m.group(2) != kind:
            continue
        rest = m.group(3)
        sm = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
        span = ('%s:%s-%s:%s' % sm.groups()) if sm else 'NOLOC'
        nm = re.match(r'^\(([^)]*)\)', rest)
        name = nm.group(1) if nm else ''
        f, vpfx, vtxt = own_fields(lines, i)
        yield span, name, f, vpfx, vtxt
