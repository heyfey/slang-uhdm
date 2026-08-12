#!/usr/bin/env python3
"""r10svs9 — read every EVENT CONTROL's condition out of a uhdm-dump, on BOTH
sides, keyed by SOURCE SPAN so the two sides are compared cell-for-cell rather
than by position in the file.

    usage: ecread.py g.dump o.dump [--all]

Why a reader and not `grep`: uhdm-dump prints `vpiParent` as a FULL inline
back-pointer, so the same `event_control` line appears once as the real node and
once (or more) under every child's `|vpiParent:`.  A grep count double-counts.
This walks the indent column and only descends into a field that is NOT
`vpiParent`, which is the same rule r10svs5repro/gridread.sh used.

Output, one line per event control, LHS=golden first:
    <span>  <cond-kind>(<name>) <cond-span> [ elems: kind(name)@span ; ... ]
"""
import re
import sys

OBJ = re.compile(r'^(\s*)\\_(\w+): (\([^)]*\))?, line:(\d+):(\d+), endln:(\d+):(\d+)')
FLD = re.compile(r'^(\s*)\|(\w+):(.*)$')


def parse(path):
    """Return a list of (indent, kind, span, decor) plus each node's field map,
    skipping every subtree reached through vpiParent."""
    lines = open(path, 'rt', errors='replace').read().splitlines()
    nodes = []          # (idx, indent, kind, span)
    for i, ln in enumerate(lines):
        m = OBJ.match(ln)
        if not m:
            continue
        nodes.append((i, len(m.group(1)), m.group(2),
                      '%s:%s-%s:%s' % (m.group(4), m.group(5),
                                       m.group(6), m.group(7))))
    return lines, nodes


def field_of(lines, idx):
    """The `|field:` line immediately above object line idx, if any."""
    j = idx - 1
    while j >= 0 and lines[j].strip() == '':
        j -= 1
    if j < 0:
        return None
    m = FLD.match(lines[j])
    return m.group(2) if m else None


def scalar_fields(lines, idx, indent):
    """`|name:value` scalars printed directly under the object at idx."""
    out = {}
    j = idx + 1
    while j < len(lines):
        ln = lines[j]
        if not ln.strip():
            j += 1
            continue
        cur = len(ln) - len(ln.lstrip())
        if cur <= indent and not FLD.match(ln):
            break
        m = FLD.match(ln)
        if m and len(m.group(1)) == indent + 2:
            if m.group(3) != '':
                out[m.group(2)] = m.group(3)
            j += 1
            continue
        mo = OBJ.match(ln)
        if mo and len(mo.group(1)) <= indent:
            break
        j += 1
    return out


def children(lines, nodes, k):
    """Direct object children of nodes[k], with the field that reached them,
    skipping vpiParent back-pointers."""
    idx, indent, _, _ = nodes[k]
    out = []
    for j in range(k + 1, len(nodes)):
        jidx, jind, jkind, jspan = nodes[j]
        if jind <= indent:
            break
        if jind != indent + 2:
            continue
        f = field_of(lines, jidx)
        if f == 'vpiParent':
            continue
        out.append((j, f, jkind, jspan, jidx, jind))
    return out


def name_of(lines, nodes, k):
    idx, indent, kind, span = nodes[k]
    sf = scalar_fields(lines, idx, indent)
    return sf.get('vpiName', ''), sf.get('vpiFullName', '')


def describe(lines, nodes, k, depth=0):
    idx, indent, kind, span = nodes[k]
    nm, fn = name_of(lines, nodes, k)
    s = '%s(%s%s)@%s' % (kind, nm, '|full=' + fn if fn else '', span)
    kids = [c for c in children(lines, nodes, k) if c[1] == 'vpiActual']
    if kids:
        s += '{' + '; '.join(describe(lines, nodes, c[0], depth + 1)
                             for c in kids) + '}'
    return s


def event_controls(path):
    lines, nodes = parse(path)
    out = {}
    for k, (idx, indent, kind, span) in enumerate(nodes):
        if kind != 'event_control':
            continue
        if field_of(lines, idx) == 'vpiParent':
            continue
        conds = [c for c in children(lines, nodes, k)
                 if c[1] in ('vpiCondition', 'vpiExpr')]
        desc = ' + '.join(describe(lines, nodes, c[0]) for c in conds) or '<none>'
        out.setdefault(span, []).append(desc)
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    g, o = args[0], args[1]
    G, O = event_controls(g), event_controls(o)
    keys = sorted(set(G) | set(O),
                  key=lambda s: [int(x) for x in re.split(r'[:-]', s)])
    eq = 0
    for kspan in keys:
        gv = G.get(kspan, ['<ABSENT>'])
        ov = O.get(kspan, ['<ABSENT>'])
        mark = 'EQ ' if gv == ov else 'DIFF'
        if gv == ov:
            eq += 1
        print('%s  ec@%s' % (mark, kspan))
        print('      G: %s' % ' || '.join(gv))
        if gv != ov:
            print('      O: %s' % ' || '.join(ov))
    print('---- event controls: %d  EQ %d  DIFF %d' % (len(keys), eq,
                                                       len(keys) - eq))


if __name__ == '__main__':
    main()
