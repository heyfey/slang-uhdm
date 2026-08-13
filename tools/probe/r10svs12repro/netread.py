#!/usr/bin/env python3
"""r10svs11 grid reader — the DIRECT Nets() listing of a named instance.

The head this pass targets is a VECTOR-SIZE mismatch on `module_inst work@top`'s
Nets(), so the cell being measured is *membership of that one vector*, not a
subtree.  Reading it with grep is wrong for two reasons this pass paid for:

  * uhdm-dump reprints a net inside OTHER objects (as `vpiParent`, as a
    `vpiActual`, inside a `ref_obj`), so `grep logic_net` over the subtree
    over-counts wildly;
  * the dump nests by an INDENT COLUMN, and only the lines at the object's own
    indent+2 under a `|vpiNet:` label are members of ITS vector.

So we walk the indent column: find the object header line whose text matches
--obj at some indent I, then collect the `\\_<kind>: (<name>)` lines at indent
I+2 that are immediately preceded by a `|<field>:` label line at indent I+2.

Cells are keyed by (field, object kind, name, span) on BOTH sides.

usage: netread.py <dump> --obj 'module_inst: work@top ' [--field vpiNet]
       netread.py <g.dump> <o.dump> --obj ... --field ...   (two-sided table)
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


def read_members(path, objpat, field):
    """Return the ordered list of members of <objpat>'s <field> vector.

    Only the FIRST occurrence of the object at its own indent is used: uhdm-cmp
    prints the failing object twice and uhdm-dump reprints it as a back-pointer,
    and both copies would otherwise double the census.
    """
    lines = open(path, encoding='utf-8', errors='replace').read().splitlines()
    # locate the object header
    start = None
    base = None
    for i, ln in enumerate(lines):
        m = HDR.match(ln)
        txt = ln.lstrip()
        if m and txt.startswith('\\_' + objpat):
            start, base = i, indent_of(ln)
            break
        # the dump's root object has no '\_' prefix
        if start is None and ln.startswith(objpat):
            start, base = i, 0
            break
    if start is None:
        return None
    out = []
    j = start + 1
    curfield = None
    while j < len(lines):
        ln = lines[j]
        if not ln.strip():
            j += 1
            continue
        ind = indent_of(ln)
        if ind <= base and not ln.startswith(' ' * (base + 2)):
            # left the object's subtree
            if ind <= base:
                break
        f = FLD.match(ln)
        h = HDR.match(ln)
        if f and ind == base + 2:
            curfield = f.group('name')
        elif h and ind == base + 2:
            if curfield == field:
                rest = h.group('rest')
                nm = ''
                mn = re.match(r'\(([^)]*)\)', rest)
                if mn:
                    nm = mn.group(1)
                sp = SPAN.search(rest)
                out.append((h.group('kind'), nm,
                            (sp.group(1) + '-' + sp.group(2)) if sp else '-'))
        j += 1
    return out


def main():
    args = [a for a in sys.argv[1:]]
    obj = 'module_inst: work@top '
    field = 'vpiNet'
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
    sides = []
    for f in files:
        sides.append(read_members(f, obj, field))
    if len(sides) == 1:
        r = sides[0]
        if r is None:
            print('OBJECT NOT FOUND: ' + obj)
            return 2
        print('%s  %s  n=%d' % (obj, field, len(r)))
        for k, n, s in r:
            print('   %-14s %-40s %s' % (k, n, s))
        return 0
    g, o = sides[0], sides[1]
    if g is None or o is None:
        print('OBJECT NOT FOUND on %s side' % ('LHS' if g is None else 'RHS'))
        return 2
    print('LHS golden n=%d   RHS ours n=%d   (%s / %s)' %
          (len(g), len(o), obj.strip(), field))
    keys = []
    for e in g + o:
        if e not in keys:
            keys.append(e)
    print('  %-6s %-14s %-34s %-24s' % ('WHERE', 'kind', 'name', 'span'))
    for k in keys:
        where = ('BOTH' if (k in g and k in o) else
                 ('GOLDEN-ONLY' if k in g else 'OURS-ONLY'))
        print('  %-11s %-14s %-34s %-24s' % (where, k[0], k[1], k[2]))
    return 0


if __name__ == '__main__':
    sys.exit(main())
