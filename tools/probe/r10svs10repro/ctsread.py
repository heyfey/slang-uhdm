#!/usr/bin/env python3
"""r10svs10 — read every CLASS-HANDLE SIGNAL out of a uhdm-dump, on BOTH sides,
keyed by (declaring instance, name, source span) so the two sides are compared
CELL-FOR-CELL rather than by position in the file.

    usage: ctsread.py g.dump o.dump [--all]

Why a reader and not `grep`: uhdm-dump prints `vpiParent` as a FULL inline
back-pointer, so the very `logic_net` we are measuring appears again nested
underneath its own `ref_typespec`'s `|vpiParent:`.  A grep for `class_typespec`
under a net therefore counts the net's own subtree twice and a grep for
`ref_typespec` finds one even when the net has none (it belongs to a sibling).
This walks the INDENT COLUMN and descends only into fields that are NOT
vpiParent -- the same rule r10svs9repro/ecread.py used.

A cell's VALUE is the typespec chain the signal carries:
    TS(<class name>)  vpiTypespec -> ref_typespec -> vpiActual class_typespec
    TS?(<kind>)       a typespec chain ending in something else
    RT-NOACT          a ref_typespec whose vpiActual is absent
    NONE              no vpiTypespec at all   <-- the head's RHS
LHS is ALWAYS golden; RHS is ALWAYS ours.
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_(\w+): (\(([^)]*)\))?(.*)$')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')
LOC = re.compile(r'line:(\d+):(\d+), endln:(\d+):(\d+)')

# The object kinds a class handle can be emitted as, in either view.
SIGKINDS = {'logic_net', 'class_var', 'logic_var', 'array_net', 'array_var',
            'chandle_var', 'struct_net', 'enum_net', 'variables'}
# The kinds that DECLARE a scope we key cells by.
SCOPEKINDS = {'module_inst', 'program', 'interface_inst', 'gen_scope',
              'gen_scope_array', 'package', 'class_defn', 'design'}


def parse(path):
    lines = open(path, 'rt', errors='replace').read().splitlines()
    nodes = []
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if m:
            nodes.append((i, len(m.group(1)), m.group(2), m.group(4) or '',
                          m.group(5)))
    return lines, nodes


def span(rest):
    m = LOC.search(rest or '')
    return '%s:%s-%s:%s' % m.groups() if m else '-'


def field_above(lines, idx):
    """The `|field:` line immediately above object line idx, if any."""
    j = idx - 1
    while j >= 0 and lines[j].strip() == '':
        j -= 1
    if j < 0:
        return None
    m = FLD.match(lines[j])
    return m.group(2) if m else None


def collect(path):
    """Walk the tree, skipping every subtree reached through vpiParent, and
    return one record per class-handle signal: (scope, name, span, value)."""
    lines, nodes = parse(path)
    out = []
    # stack of (indent, kind, decor) for the live ancestor chain
    stack = []
    skip_indent = None
    for pos, (idx, ind, kind, decor, rest) in enumerate(nodes):
        # leaving a skipped vpiParent subtree?
        if skip_indent is not None:
            if ind > skip_indent:
                continue
            skip_indent = None
        fld = field_above(lines, idx)
        if fld == 'vpiParent':
            skip_indent = ind
            continue
        while stack and stack[-1][0] >= ind:
            stack.pop()
        if kind in SIGKINDS and decor:
            scope = next((d for (i2, k2, d2) in reversed(stack)
                          for d in [d2] if k2 in SCOPEKINDS), '?')
            out.append((scope, decor, span(rest), kind,
                        value_of(lines, nodes, pos, ind)))
        stack.append((ind, kind, decor))
    return out


def value_of(lines, nodes, pos, ind):
    """The typespec chain hanging off the signal at nodes[pos]."""
    # find the vpiTypespec child (not a vpiParent back-pointer)
    skip = None
    for (idx2, ind2, kind2, decor2, rest2) in nodes[pos + 1:]:
        if ind2 <= ind:
            break
        if skip is not None:
            if ind2 > skip:
                continue
            skip = None
        f2 = field_above(lines, idx2)
        if f2 == 'vpiParent':
            skip = ind2
            continue
        if f2 == 'vpiTypespec' and ind2 == ind + 2:
            if kind2 != 'ref_typespec':
                return 'TS?(%s)' % kind2
            # its vpiActual
            skip3 = None
            for (idx3, ind3, kind3, decor3, rest3) in nodes[
                    nodes.index((idx2, ind2, kind2, decor2, rest2)) + 1:]:
                if ind3 <= ind2:
                    break
                if skip3 is not None:
                    if ind3 > skip3:
                        continue
                    skip3 = None
                f3 = field_above(lines, idx3)
                if f3 == 'vpiParent':
                    skip3 = ind3
                    continue
                if f3 == 'vpiActual':
                    if kind3 == 'class_typespec':
                        return 'TS(%s)@%s' % (decor3 or '<anon>', span(rest3))
                    return 'TS?(%s)' % kind3
            return 'RT-NOACT'
    return 'NONE'


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    g, o = collect(sys.argv[1]), collect(sys.argv[2])
    allcells = sys.argv[3:] == ['--all']

    def key(r):
        return (r[0], r[1], r[2], r[3])

    gm, om = {}, {}
    for r in g:
        gm.setdefault(key(r), []).append(r[4])
    for r in o:
        om.setdefault(key(r), []).append(r[4])
    keys = sorted(set(gm) | set(om))
    eq = ne = 0
    print('%-34s %-13s %-11s %-26s %-26s' %
          ('SIGNAL (scope/name)', 'span', 'kind', 'GOLDEN', 'OURS'))
    for k in keys:
        gv = ' | '.join(gm.get(k, ['<absent>']))
        ov = ' | '.join(om.get(k, ['<absent>']))
        same = gv == ov
        eq += same
        ne += not same
        if same and not allcells:
            continue
        print('%-34s %-13s %-11s %-26s %-26s %s' %
              (k[1][:34], k[2], k[3][:11], gv[:26], ov[:26],
               'EQ' if same else 'DIFF'))
    print('\ncells: %d  EQ %d  DIFF %d' % (eq + ne, eq, ne))


if __name__ == '__main__':
    main()
