#!/usr/bin/env python3
"""r10svs14 THE CELL READER — the col-0 TAIL DUP's Variables(), both sides.

    usage: dupread.py <golden.dump> <ours.dump> [--obj '(work@top.i1)' ...]
           dupread.py <golden.dump> <ours.dump> --all

WHY IT IS NOT A GREP.  Every UHDM object is reprinted inside its own children as
a `vpiParent` back-pointer, and a tail-dup element is reprinted a THIRD time as
the modport io_decl's `vpiExpr`.  A grep over an interface's name therefore
over-counts by a factor that depends on the shape.  This walks the dump's INDENT
COLUMN instead: an object's OWN LISTING is the occurrence of its header with the
LARGEST subtree (a back-pointer reprint has a subtree of ZERO lines), and its OWN
`vpiVariables` are the field labels at EXACTLY its indent + 2.

THE TWO VIEWS ARE KEYED APART BY THE COLUMN, NOT BY THE NAME.  Surelog gives the
col-0 tail duplicate the SAME vpiName and vpiFullName as the home view and
distinguishes it by `line:N:0` with NO `endln` (reference style).  So:
    DUP   col == 0 and no endln
    HOME  col  > 0 (it carries endln)
A reader keyed on the fullname alone reports the home view's numbers for the dup
and the localization silently becomes unfalsifiable.

LHS is ALWAYS golden, RHS is ALWAYS ours.
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_(\w+): (?:(\S+) )?\((.*?)\)(.*)$')


def parse(path):
    out = []
    with open(path) as f:
        for line in f.read().split('\n'):
            m = re.match(r'^(\s*)(.*)$', line)
            out.append((len(m.group(1)), m.group(2), line))
    return out


def subtree_len(lines, i):
    ind = lines[i][0]
    j = i + 1
    while j < len(lines) and lines[j][1] and lines[j][0] >= ind + 2:
        j += 1
    return j - i - 1


def fields(lines, i):
    """Direct field labels of the object at i, in order, each with its value
    line (the next line at the same indent, if it is an object header)."""
    ind = lines[i][0]
    j = i + 1
    out = []
    while j < len(lines) and lines[j][1] and lines[j][0] >= ind + 2:
        if lines[j][0] == ind + 2 and lines[j][1].startswith('|'):
            lab = lines[j][1]
            val = None
            if j + 1 < len(lines) and lines[j + 1][0] == ind + 2 and \
                    lines[j + 1][1].startswith('\\_'):
                val = lines[j + 1][1]
            out.append((lab, val))
        j += 1
    return out


def ifaces(path):
    """{key: (kind, defname, fullname, span, isdup, own_index)} own listings."""
    lines = parse(path)
    best = {}
    for i, (ind, txt, _) in enumerate(lines):
        m = HDR.match(lines[i][2])
        if not m or m.group(2) != 'interface_inst':
            continue
        defname, full, tail = m.group(3) or '', m.group(4), m.group(5)
        sp = re.search(r'line:(\d+):(\d+)', tail)
        col = int(sp.group(2)) if sp else -1
        isdup = (col == 0 and 'endln' not in tail)
        span = sp.group(0) if sp else '?'
        key = (defname, full, 'DUP' if isdup else 'HOME')
        n = subtree_len(lines, i)
        if key not in best or n > best[key][0]:
            best[key] = (n, i, span, isdup)
    return lines, best


def varlist(lines, i):
    out = []
    for lab, val in fields(lines, i):
        if lab != '|vpiVariables:' or val is None:
            continue
        m = re.match(r'^\\_(\w+): \((.*?)\)', val)
        out.append('%s %s' % (m.group(1), m.group(2).split('.')[-1]) if m else val)
    return out


def netlist(lines, i):
    out = []
    for lab, val in fields(lines, i):
        if lab not in ('|vpiNets:', '|vpiArrayNet:') or val is None:
            continue
        m = re.match(r'^\\_(\w+): \((.*?)\)', val)
        out.append('%s %s' % (m.group(1), m.group(2).split('.')[-1]) if m else val)
    return out


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    g, o = sys.argv[1], sys.argv[2]
    want = [a for k, a in zip(sys.argv[3:], sys.argv[4:]) if k == '--obj']
    show_all = '--all' in sys.argv
    gl, gb = ifaces(g)
    ol, ob = ifaces(o)
    keys = sorted(set(gb) | set(ob), key=lambda k: (k[1], k[2]))
    eq = dif = 0
    for key in keys:
        defname, full, view = key
        if not show_all and want and not any(w.strip('()') == full for w in want):
            continue
        gv = varlist(gl, gb[key][1]) if key in gb else None
        ov = varlist(ol, ob[key][1]) if key in ob else None
        gn = netlist(gl, gb[key][1]) if key in gb else None
        on = netlist(ol, ob[key][1]) if key in ob else None
        same = (gv == ov)
        eq, dif = (eq + 1, dif) if same else (eq, dif + 1)
        print('OBJ %-5s %-28s %s   %s' % (view, defname, full,
                                          'EQ' if same else 'DIF'))
        print('    GOLDEN vars %s: %s' %
              ('ABSENT' if gv is None else len(gv), gv))
        print('    OURS   vars %s: %s' %
              ('ABSENT' if ov is None else len(ov), ov))
        if gn or on:
            print('    (nets  G %s / O %s)' % (gn, on))
    print('CELLS %d   EQ %d   DIF %d' % (eq + dif, eq, dif))
    return 0


sys.exit(main())
