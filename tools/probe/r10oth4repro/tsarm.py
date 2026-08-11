#!/usr/bin/env python3
"""tsarm.py -- for every `param_assign` in a uhdm-dump, print the RHS constant
and the ACTUAL TYPESPEC behind its ref_typespec, with the typespec's range
bounds.  This is the instrument for HEAD 2 of YosysOldOr
(§ srlgParamDeclNonLastTs): the differing field is
`param_assign -> vpiRhs constant -> vpiTypespec ref_typespec -> vpiActual`,
which no earlier probe in this campaign printed.

Output, one line per param_assign:

    <view> <module> pa@<span> lhs=<name> const=<TAG>:<val> sz<size> ts=<kind>@<span> [L,R]

A dump prints the vpiActual payload as a BARE HEADER (kind + span, no children),
so the range bounds are NOT available at the reference site.  They ARE available
at the typespec's own DEFINITION elsewhere in the dump, so this script indexes
every typespec definition by (kind, span) first and then joins.  A (kind, span)
that resolves to more than one distinct bound pair is reported as `AMBIG` rather
than silently picking one -- a locationless typespec has span `-` and several of
them can coexist, which is exactly the head's shape.

POSITIVE CONTROL: `--expect N` exits 3 if fewer than N param_assigns are found.
"""
import re
import sys

HDR = re.compile(r'^(\s*)\\_([A-Za-z_]+):\s*(.*)$')
EDGE = re.compile(r'^(\s*)\|([A-Za-z_]+):\s*(.*)$')
SPAN = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')


def spanof(rest):
    m = SPAN.search(rest)
    return '%s:%s-%s:%s' % m.groups() if m else '-'


def index_typespecs(lines):
    """(kind, span) -> set of 'L,R' bound strings, from DEFINITIONS only."""
    idx = {}
    i = 0
    while i < len(lines):
        m = HDR.match(lines[i])
        if m and m.group(2).endswith('_typespec') and m.group(2) != 'ref_typespec':
            ind = len(m.group(1))
            kind, span = m.group(2), spanof(m.group(3))
            # a DEFINITION owns children at deeper indent; a back-reference has none
            j, bounds, seen_child = i + 1, [], False
            while j < len(lines):
                mj = HDR.match(lines[j]) or EDGE.match(lines[j])
                if not mj or len(mj.group(1)) <= ind:
                    break
                seen_child = True
                mm = re.search(r'\|(INT|UINT):(-?\d+)', lines[j])
                if mm:
                    bounds.append('%s:%s' % mm.groups())
                j += 1
            if seen_child:
                idx.setdefault((kind, span), set()).add(','.join(bounds) or '-')
            i = j
            continue
        i += 1
    return idx


def main():
    expect = 0
    args = list(sys.argv[1:])
    if '--expect' in args:
        k = args.index('--expect')
        expect = int(args[k + 1])
        del args[k:k + 2]
    if len(args) != 1:
        sys.exit('usage: tsarm.py [--expect N] <dump>')
    lines = open(args[0], errors='replace').read().splitlines()
    tsidx = index_typespecs(lines)

    view, mod = 'PRE', '?'
    out = []
    i = 0
    while i < len(lines):
        ln = lines[i]
        if 'uhdmallModules' in ln:
            view = 'DEF'
        elif 'uhdmtopModules' in ln:
            view = 'ELAB'
        m = re.search(r'\\_module_inst: (\S+)', ln)
        if m:
            mod = m.group(1).split('@')[-1]
        m = HDR.match(ln)
        if m and m.group(2) == 'param_assign':
            ind = len(m.group(1))
            pa = spanof(m.group(3))
            const, sz, ts, lhs = '-', '-', '-', '-'
            j = i + 1
            inrhs = False
            while j < len(lines):
                mj = HDR.match(lines[j]) or EDGE.match(lines[j])
                if not mj or len(mj.group(1)) <= ind:
                    break
                t = lines[j].strip()
                if t == '|vpiRhs:':
                    inrhs = True
                if t == '|vpiLhs:':
                    inrhs = False
                if inrhs:
                    mm = re.search(r'\|(BIN|HEX|OCT|DEC|INT|UINT):(\S*)', lines[j])
                    if mm and const == '-':
                        const = '%s:%s' % mm.groups()
                    mm = re.search(r'\|vpiSize:(\d+)', lines[j])
                    if mm and sz == '-':
                        sz = mm.group(1)
                    mh = HDR.match(lines[j])
                    if mh and mh.group(2).endswith('_typespec') and \
                            mh.group(2) != 'ref_typespec' and ts == '-':
                        ts = '%s@%s' % (mh.group(2), spanof(mh.group(3)))
                else:
                    mh = HDR.match(lines[j])
                    if mh and mh.group(2) == 'parameter':
                        mm = re.search(r'\((\S+)\)', mh.group(3))
                        if mm and lhs == '-':
                            lhs = mm.group(1).split('.')[-1]
                j += 1
            b = '-'
            if ts != '-':
                kind, span = ts.split('@', 1)
                s = tsidx.get((kind, span))
                b = ('AMBIG' + str(sorted(s))) if s and len(s) > 1 else \
                    (next(iter(s)) if s else '?')
            out.append('%-4s %-14s pa@%-16s lhs=%-6s const=%-14s sz%-4s ts=%-38s [%s]'
                       % (view, mod, pa, lhs, const, sz, ts, b))
            i = j
            continue
        i += 1

    for o in out:
        print(o)
    if len(out) < expect:
        sys.stderr.write('tsarm: PROBE NOT FOUND -- %d param_assigns, expected '
                         '>=%d\n' % (len(out), expect))
        sys.exit(3)


if __name__ == '__main__':
    main()
