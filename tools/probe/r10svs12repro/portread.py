#!/usr/bin/env python3
"""r10svs12 grid reader — the DIRECT vpiPort listing of one named container.

The head this pass targets is a `port` of a `module_array`, and the compared
fields are the port's own `vpiName` (ports::Compare, via BaseClass::Compare)
and — one level down — the HighConn ref's `vpiFullName`.  So the cell is a
TRIPLE per port: (name, span, highconn-fullname), read off the DIRECT members
of the container's vpiPort vector.

Reading it with grep is wrong for the same two reasons r10svs11's netread.py
records: uhdm-dump reprints a port inside its own children as a `vpiParent`
back-pointer, and the dump nests by an INDENT COLUMN, so only the lines at the
container's own indent+2 under a `|vpiPort:` label are members of ITS vector.
This walks the indent column instead.

The port SPAN is printed because golden's positional-conn port is anchored at
the ACTUAL while its named-conn port spans the whole `.formal(actual)` text —
but note it is NOT a compared field (BaseClass::Compare compares VpiType /
VpiName / VpiDefName only; ports::Compare adds PortIndex/PortType/Scalar/
Vector/ConnByName/Direction/Size/ExplicitName and the singular children).  It
is reported as EVIDENCE of which syntax node golden built the port from, and
labelled as uncompared wherever it is quoted.

usage: portread.py <g.dump> <o.dump> --obj '<kind>: <hdr-prefix>'
       portread.py <dump> --obj ...
       (--field defaults to vpiPort)
"""
import re
import sys


def indent_of(line):
    n = 0
    while n < len(line) and line[n] == ' ':
        n += 1
    return n


HDR = re.compile(r'^(?P<ind> *)\\_(?P<kind>[A-Za-z_0-9]+): (?P<rest>.*)$')
FLD = re.compile(r'^(?P<ind> *)\|(?P<name>[A-Za-z_0-9]+):(?P<val>.*)$')
SPAN = re.compile(r'line:(\d+:\d+), endln:(\d+:\d+)')


def span_of(rest):
    m = SPAN.search(rest)
    return (m.group(1) + '-' + m.group(2)) if m else 'NOSPAN'


def name_of(rest):
    m = re.match(r'\(([^)]*)\)', rest)
    return m.group(1) if m else ''


def subtree(lines, start):
    """The index range of the object header at lines[start] and its subtree."""
    base = indent_of(lines[start])
    j = start + 1
    while j < len(lines):
        if lines[j].strip() and indent_of(lines[j]) <= base:
            break
        j += 1
    return start, j


def read_ports(path, objpat, field='vpiPort'):
    """(container-span, [ (portname, portspan, hcKind, hcName, hcFullName) ]).

    Only the FIRST occurrence of the container at its own indent is used.
    """
    lines = open(path, encoding='utf-8', errors='replace').read().splitlines()
    start = None
    base = None
    for i, ln in enumerate(lines):
        txt = ln.lstrip()
        if HDR.match(ln) and txt.startswith('\\_' + objpat):
            start, base = i, indent_of(ln)
            break
        if start is None and ln.startswith(objpat):
            start, base = i, 0
            break
    if start is None:
        return None, None
    cspan = span_of(lines[start].split(': ', 1)[1] if ': ' in lines[start] else '')
    out = []
    j = start + 1
    curfield = None
    while j < len(lines):
        ln = lines[j]
        if not ln.strip():
            j += 1
            continue
        ind = indent_of(ln)
        if ind <= base:
            break
        f = FLD.match(ln)
        h = HDR.match(ln)
        if f and ind == base + 2:
            curfield = f.group('name')
        elif h and ind == base + 2 and curfield == field:
            a, b = subtree(lines, j)
            pname = None
            pspan = span_of(h.group('rest'))
            hc = ('-', '-', '-')
            pind = indent_of(lines[a])
            k = a + 1
            pf = None
            while k < b:
                l2 = lines[k]
                if not l2.strip():
                    k += 1
                    continue
                i2 = indent_of(l2)
                f2 = FLD.match(l2)
                h2 = HDR.match(l2)
                if f2 and i2 == pind + 2:
                    pf = f2.group('name')
                    if pf == 'vpiName':
                        pname = f2.group('val')
                elif h2 and i2 == pind + 2 and pf == 'vpiHighConn':
                    c, d = subtree(lines, k)
                    full = '-'
                    hcn = name_of(h2.group('rest'))
                    kk = c + 1
                    while kk < d:
                        f3 = FLD.match(lines[kk])
                        if f3 and indent_of(lines[kk]) == i2 + 2 and \
                                f3.group('name') == 'vpiFullName':
                            full = f3.group('val')
                        kk += 1
                    hc = (h2.group('kind'), hcn, full)
                k += 1
            out.append((pname if pname is not None else '<EMPTY>',
                        pspan, hc[0], hc[1], hc[2]))
            j = b
            continue
        j += 1
    return cspan, out


def fmt(rows):
    return ['name=%-12s span=%-22s hc=%s(%s) full=%s' % r for r in rows]


def main():
    args = list(sys.argv[1:])
    obj = None
    field = 'vpiPort'
    files = []
    i = 0
    while i < len(args):
        if args[i] == '--obj':
            obj = args[i + 1]
            i += 2
        elif args[i] == '--field':
            field = args[i + 1]
            i += 2
        else:
            files.append(args[i])
            i += 1
    if not obj:
        print('need --obj')
        return 2
    sides = [read_ports(f, obj, field) for f in files]
    if len(sides) == 1:
        cs, r = sides[0]
        if r is None:
            print('OBJECT NOT FOUND: ' + obj)
            return 2
        print('%s  (span %s)  %s n=%d' % (obj, cs, field, len(r)))
        for line in fmt(r):
            print('   ' + line)
        return 0
    (gc, g), (oc, o) = sides[0], sides[1]
    if g is None or o is None:
        print('OBJECT NOT FOUND on %s side (%s)' %
              ('LHS golden' if g is None else 'RHS ours', obj))
        return 2
    print('== %s   LHS golden n=%d (span %s)   RHS ours n=%d (span %s)' %
          (obj.strip(), len(g), gc, len(o), oc))
    gl, ol = fmt(g), fmt(o)
    n = max(len(gl), len(ol))
    for i in range(n):
        a = gl[i] if i < len(gl) else '<absent>'
        b = ol[i] if i < len(ol) else '<absent>'
        print('  %s  LHS %s' % ('EQ ' if a == b else 'DIF', a))
        if a != b:
            print('      RHS %s' % b)
    print('  CELLS eq=%d dif=%d' %
          (sum(1 for i in range(n)
               if i < len(gl) and i < len(ol) and gl[i] == ol[i]),
           sum(1 for i in range(n)
               if not (i < len(gl) and i < len(ol) and gl[i] == ol[i]))))
    return 0


if __name__ == '__main__':
    sys.exit(main())
