#!/usr/bin/env python3
"""r10earl50 census -- span-keyed census of the ELABORATED view's
`param_assign` RHS typespec linkage.

The 66-line head of Earlgrey_0_1/default is NOT a range fold: golden's
elaborated `param_assign` RHS constant carries a **span-less, fully folded**
`logic_typespec` as its `ref_typespec`'s `vpiActual`, where we carry the
*declaration's* span-bearing `logic_typespec` whose range is still an
`operation`.  This script enumerates, per dump, every

    param_assign -> vpiRhs -> constant -> vpiTypespec -> ref_typespec
                 -> vpiActual -> <typespec kind, span>

together with the LHS parameter name, so the two dumps can be compared cell by
cell.  It parses the uhdm-dump indentation tree (object lines are
`<indent>\\_kind: rest`, property lines are `<indent>|name:value`; an object's
own properties/children sit at indent+2).

  usage: census50.py <dump> <first-line> <last-line> [--all-typespecs]
"""
import sys
import re

OBJ = re.compile(r'^( *)\\_([a-zA-Z_]+): ?(.*)$')
PROP = re.compile(r'^( *)\|([a-zA-Z_]+):(.*)$')


def span_of(rest):
    m = re.search(r'line:(\d+):(\d+), endln:(\d+):(\d+)', rest)
    if not m:
        return 'NOSPAN'
    return '%s:%s-%s:%s' % m.groups()


def name_of(rest):
    m = re.match(r'^([^,(]*)\(([^)]*)\)', rest)
    if m:
        return m.group(2)
    m = re.match(r'^([A-Za-z_][\w@.\[\]$]*)', rest.strip())
    return m.group(1) if m else ''


def parse(path, lo, hi):
    """Yield (lineno, indent, kind, rest, owning_prop, parent_key)."""
    stack = {}          # indent -> (kind, rest, lineno)
    lastprop = {}       # indent -> prop name
    out = []
    with open(path, 'rb') as f:
        for n, raw in enumerate(f, 1):
            if n < lo:
                continue
            if n > hi:
                break
            line = raw.decode('utf-8', 'replace').rstrip('\n')
            m = PROP.match(line)
            if m:
                lastprop[len(m.group(1))] = m.group(2)
                continue
            m = OBJ.match(line)
            if not m:
                continue
            ind = len(m.group(1))
            kind, rest = m.group(2), m.group(3)
            prop = lastprop.get(ind, '')
            par = stack.get(ind - 2)
            out.append((n, ind, kind, rest, prop, par))
            stack[ind] = (kind, rest, n)
            # entering a new object invalidates deeper state
            for k in [k for k in list(stack) if k > ind]:
                del stack[k]
            for k in [k for k in list(lastprop) if k > ind]:
                del lastprop[k]
    return out


def main():
    path, lo, hi = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    allts = '--all-typespecs' in sys.argv
    nodes = parse(path, lo, hi)
    # index by lineno for parent lookup of the *chain* we care about
    # walk: find ref_typespec whose owning prop is vpiTypespec and whose
    # parent is a constant; then its vpiActual child.
    by_line = {n[0]: n for n in nodes}
    order = [n[0] for n in nodes]
    pos = {ln: i for i, ln in enumerate(order)}
    rows = []
    for i, nd in enumerate(nodes):
        ln, ind, kind, rest, prop, par = nd
        if kind != 'ref_typespec' or prop != 'vpiTypespec':
            continue
        if par is None or par[0] != 'constant':
            continue
        # the constant's own owning prop / parent: look back for the constant
        # node itself
        cst = None
        for j in range(i - 1, -1, -1):
            if nodes[j][0] == par[2]:
                cst = nodes[j]
                break
        if cst is None:
            continue
        if not allts and cst[4] != 'vpiRhs':
            continue
        if not allts and (cst[5] is None or cst[5][0] != 'param_assign'):
            continue
        # find the vpiActual child of this ref_typespec (indent ind+2)
        act = None
        for j in range(i + 1, len(nodes)):
            n2 = nodes[j]
            if n2[1] <= ind:
                break
            if n2[1] == ind + 2 and n2[4] == 'vpiActual':
                act = n2
                break
        pa_span = span_of(cst[5][1]) if cst[5] else '?'
        rows.append('%-24s pa=%-16s rhs=%-14s ref=%-42s actual=%s@%s' % (
            'PARAM_ASSIGN_RHS', pa_span, span_of(rest and cst[3] or cst[3]),
            name_of(rest), act[2] if act else 'NONE',
            span_of(act[3]) if act else '-'))
    for r in sorted(rows):
        print(r)
    print('TOTAL %d' % len(rows))


main()
